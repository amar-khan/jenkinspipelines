def targetgroup_production = "replace with targetgroup";
def list_app_instance_id
def list_app_instance_ip_address
def list


def get_ec2_instance_id(targetgroup_production){
 try {
     list_app_instance_id=[]
            ec2_instance_list = sh returnStdout: true, script: "aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:xxxxxxxxxxxxxxxxxx:targetgroup/${targetgroup_production}  --output text --query 'TargetHealthDescriptions[*].Target.Id'"
            println "Ec2 Instance Found: " + ec2_instance_list
           return ec2_instance_list
          //return "i-123333330c5"
}
  catch (err) {
        echo err
          sh "exit 1"
      }

        }

def check_import_status(instance_id){
           withCredentials([usernamePassword(credentialsId: 'app-rds-access', usernameVariable: 'hostname', passwordVariable: 'password'),
           file(credentialsId: 'app-production-pem', variable: 'FILE')
                  ])
                  {
     dir('./') {
  try {
          
                 timeout(time: 1200, unit: 'SECONDS') {
             def cmd=""
             def out_put="1"
             
             def ip= get_ec2_instance_ip_add(instance_id).trim()
             sh " ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'sudo service cron stop'"
             cmd='"'+"select count(*) from import_history where status in ('PROCESSING');"+'"'
 
              while("${out_put.toInteger()}" > 0) {  
              out_put = sh(script: "mysql -Ns -h $hostname -P 3306 -u jenkins app_db -p$password -e $cmd | tr -d ' ' | tr -d '\r' | tr -d '\n'", returnStdout: true) 
             println out_put
            if("${out_put.toInteger()}" > 0){
            println "Import in process"
             sh "sleep 30;"
             }
       else{
         println "No Import in process"
       }
              }
 }}
 

   catch (err) {
          cmd='"'+"select event_id from import_history where status in ('PROCESSING') limit 1;"+'"'
          out_put = sh(script: "mysql -Ns -h $hostname -P 3306 -u jenkins app_db -p$password -e $cmd | tr -d ' ' | tr -d '\r' | tr -d '\n'", returnStdout: true) 
          slackSend channel: "#app_infra_alerts", message: "TASK: *SERVER-UP/DOWN-GRADE* :x:\nENV NAME: *LIVE-IMPORT*\nForced-Stopped: *YES*\nEVENT_ID: *${out_put}*" ,color: "#0fc64f"

       }
                  }
 
}
}

def get_ec2_instance_ip_add(app_instance_id){
 try {
     ec2_instance_ip_add=""
 ec2_instance_ip_add = sh returnStdout: true, script: "aws ec2 describe-instances --instance-ids ${app_instance_id} --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ap-southeast-1"
        return ec2_instance_ip_add
}
  catch (err) {
        echo err
          sh "exit 1"
      }

        }

def is_cron_server(app_instance_id){
 try {
     def excip= get_ec2_instance_ip_add(app_instance_id).trim()
     def isCron="FALSE"
       withCredentials([file(credentialsId: 'app-production-pem', variable: 'FILE')]) {
       isCron = sh returnStdout: true, script: "ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$excip 'if hostname | grep -q cron ;  then echo TRUE ;fi'"
       }
       return isCron
}
  catch (err) {
        echo err
          sh "exit 1"
      }

        }

def deregister_elb_instances(targetgroup_production,instance_id){
 try {
             println "Ec2 Instance deregistered is: " + instance_id
             deregsited_instance_node = sh returnStdout: true, script: "aws elbv2 deregister-targets --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:xxxxxxxxxxxxxxxxxx:targetgroup/${targetgroup_production} --targets Id=${instance_id}"
             println deregsited_instance_node
             sleep 20;
            }          
  catch (err) {
        println err
        sh "exit 1"
      }

        }
def register_elb_instances(targetgroup_production,instance_id){
 try {
             println "Ec2 Instance registring is: " + instance_id
             regsited_instance_node = sh returnStdout: true, script: "aws elbv2 register-targets --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:xxxxxxxxxxxxxxxxxx:targetgroup/${targetgroup_production} --targets Id=${instance_id}"
             println regsited_instance_node
             sleep 30;
            }          
  catch (err) {
        println err
        sh "exit 1"
      }

        }  
def application_health_check(ip_address){
sh """
while [ "\$(curl -k -s  http://$ip_address:80)" != "Page not found. 🦄" ]; do sleep 5 ; echo "Waiting for Health Status, Need Page not found. 🦄";curl -k -s  http://$ip_address:80 ; done
"""
}              
def ec2_instances_healthcheck(instance_id,desiredState){
 try {
            def isFound=true
            def desiredStatus=""
        while(isFound) {         
       
         if("${desiredState}"=="stopped"){
               status_ec2_healthCheck = sh returnStdout: true, script: "aws ec2 describe-instances --instance-ids ${instance_id}"
          desiredStatus = readJSON text: status_ec2_healthCheck
         isFound = (desiredStatus.Reservations[0].Instances[0].State.Name.indexOf("stopped") !=-1? false: true) ;
        println "HealthCheck for Ec2 ${instance_id} Found is: " + isFound + " State Found: " +desiredStatus.Reservations[0].Instances[0].State.Name
        echo "Sleeping for 5 seconds..."
        // sleep(5)
         }
         else if("${desiredState}"=="ok"){
               status_ec2_healthCheck = sh returnStdout: true, script: "aws ec2 describe-instance-status --instance-ids ${instance_id}"
                        desiredStatus = readJSON text: status_ec2_healthCheck
               if(desiredStatus.InstanceStatuses[0]){
         isFound = (desiredStatus.InstanceStatuses[0].SystemStatus.Status.indexOf("ok") !=-1? false: true) && (desiredStatus.InstanceStatuses[0].InstanceStatus.Status.indexOf("ok") !=-1? false: true)
        println "HealthCheck for Ec2 system status ${instance_id} Found is: " + isFound + " State Found: " +desiredStatus.InstanceStatuses[0].SystemStatus.Status
        println "HealthCheck for Ec2 instance status ${instance_id} Found is: " + isFound + " State Found: " +desiredStatus.InstanceStatuses[0].InstanceStatus.Status
        echo "Sleeping for 5 seconds..."
        // sleep(5)
               }
         }
      }
      if(isFound){
          return false
      }
      else{
          return true
      }
      return isFound
      }
      catch (err) {
        echo err
      }
        }

def stop_ec2_server_node(targetgroup_production,instance_id,instance_core_type){
 try {
  def ip= get_ec2_instance_ip_add(instance_id).trim()
             withCredentials([file(credentialsId: 'app-production-pem', variable: 'FILE')]) {
                sh " ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'sudo service apache2 stop'"
                 sh "ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'sudo pkill -f register'"
                 sh "aws ec2 stop-instances --instance-ids ${instance_id}"
             if(ec2_instances_healthcheck(instance_id,"stopped")){
                 println "instance Stopped ${instance_id}"
                 def val='"{\\"Value\\"'+ ': \\"'+instance_core_type+'\\"' + '}"'
                 println val
                sh """
                 aws ec2 modify-instance-attribute --instance-id ${instance_id} --instance-type ${val}
                 """
             }
             }
            }          
  catch (err) {
        println err
        sh "exit 1"
      }

        }

def start_ec2_server_node(instance_id){
 try {
  def ip= get_ec2_instance_ip_add(instance_id).trim()
             withCredentials([file(credentialsId: 'app-production-pem', variable: 'FILE')]) {
                 
              sh """
                aws ec2 start-instances --instance-ids ${instance_id}
                 """
                 sleep 5
             if(ec2_instances_healthcheck(instance_id,"ok")){
                 println "instance Started ${instance_id}"
               // sh " ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'sudo mount -t efs fs-c37ba782:/ /efs-pimcore'"
                 sleep 2
                sh " ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'sudo service apache2 start'"
                  sh " ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'sudo service cron start'"
                  try {
                       cache_clear_op = sh returnStdout: false, script: "ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'cd /var/www/html/pimcore/bin ; sudo -u www-data php console cache:clear '"
                      sh " ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip 'sudo swapon /nswapfile'"
                     sh """
                   ssh -o StrictHostKeyChecking=no -i $FILE ubuntu@$ip "if hostname | grep -q cron ;  then echo 'MATCHED Cron Server- $ip' ; sudo service apache2 stop ; sudo pkill -f 'php console app:register' ;fi"
                   """
                  }
                    catch (err) {
        println err
      }
                

             }
             }
            }          
  catch (err) {
        println err
        sh "exit 1"
      }

        }


properties(
    [parameters(
               [choice(choices: ["NONE", "Production"].join("\n"),
               description: 'choice target enviornment parameter', 
               name: 'appenv'),
               choice(choices: ["t2.medium", "t2.large", "t2.xlarge", "c5.large", "c5.xlarge", "c5.2xlarge"].join("\n"),
               description: 'Instance Type for down/up grade', 
               name: 'instanceCoreType')
               ]
)]
)


node('master') {
     stage('GetInstanceInfo') {
       list_app_instance_id= get_ec2_instance_id(targetgroup_production)
       println list_app_instance_id
    }  
    stage('Upgrade-Downgrade') {
        script{
              if("${params.appenv}"=="Production"){
           for( String instance_id : list_app_instance_id.split("\\s") )
{
      println(instance_id);
      isCronServer= is_cron_server(instance_id)
      println isCronServer

      deregister_elb_instances(targetgroup_production,instance_id)
      check_import_status(instance_id)
      stop_ec2_server_node(targetgroup_production,instance_id,"${params.instanceCoreType}")
      sleep 5
      start_ec2_server_node(instance_id)
      register_elb_instances(targetgroup_production,instance_id)
        if("$isCronServer".contains("TRUE")){
     println "No HC required"
         }
         else{
           application_health_check(get_ec2_instance_ip_add(instance_id).trim())   
         }
}
    }}
   } 
    }        
