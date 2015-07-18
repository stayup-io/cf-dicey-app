# Dicey app deployments:
## Evaluating whether v2 is "operationally better" than v1 during a blue/green deployment...

This simple application demonstrates how the ELK-for-PCF tile gives operational insights into blue/green
deployments on Pivotal Cloud Foundry.

Specifically, it shows how firehose logs can be analysed in near real time during a zero downtime blue/green deployment
to evaluate whether v2 is operationally "better" than v1; enabling operators to decide whether to complete or roll back a  deployment.

<div align="center">
<a href="https://youtu.be/6i2Q-boiKJg"><img width="425" src="https://cloud.githubusercontent.com/assets/227505/8760628/eceef8f2-2d1f-11e5-8a41-09c00865bdd9.png"></a>
</div>

## Setup

0. Clone this repository
  ```
  git clone https://github.com/stayup-io/cf-dicey-app.git
  ```
  
0. Install [`siege`](https://www.joedog.org/siege-home/)
  ```  
  brew install siege
  ```
    
0. Push v1 of the app
  ```
  cf push cf-dicey-app-v1
  ```

0.  Make and map a route
  ```
  cf create-route SPACE DOMAIN -n HOSTNAME
  cf map-route cf-dicey-app-v1 DOMAIN -n HOSTNAME
  ```
      
0.  Scale app v1 to "production" size
  ```
  cf scale cf-dicey-app-v1 -i 5
  ```
0.  (in a new terminal) - simulate 25 user load
  ```
  siege -c25 https://HOSTNAME.DOMAIN
  ```
  
0. Open App Health dashboard
  ```
  open https://logs.CF_DOMAIN/#/dashboard/CF-App-Health
  ```
  
0. Update the dashboard's time range for a "near realtime" view
  * Last 2 min
  * 5 second refresh
  * <img width="1671" alt="screen shot 2015-07-17 at 06 20 58" src="https://cloud.githubusercontent.com/assets/227505/8741782/bde8bc98-2c55-11e5-833e-6eb7222f69dd.png">

## Deploy v2

0.  Looking at the App Health dashboard, note how v1 of the app has 2 operation issues.
   * Returns `503` errors ~ 10% of the time
   * Has a 95th percentile response time of 4s
0.  Edit `app.rb` and code up a "fix"
   * comment out line 9
   * uncomment line 10
0.  Start Blue/Green deploy
   ```
  cf push cf-dicey-app-v2
  cf map-route cf-dicey-app-v2 DOMAIN -n HOSTNAME
  ```
  
0.  Consult the App Heath dashboard, notice:
  * 1/6th of the "production" traffic goes to `cf-dicey-app-v2`
  * Woops!  `cf-dicey-app-v2` actually has more `503` errors, and a worse 95th percentile response time!
  * <img width="1669" alt="screen shot 2015-07-17 at 06 24 13" src="https://cloud.githubusercontent.com/assets/227505/8741781/ba2d5136-2c55-11e5-8b1a-8e66b01604f1.png">

0.  Abort the deploy
  ```
  cf delete cf-dicey-app-v2 -f
  ```
  
## Deploy v3
0.  Edit `app.rb` and code up a "fix"
   * comment out line 10
   * uncomment line 11
0.  Start Blue/Green deploy
  ```
  cf push cf-dicey-app-v3
  cf map-route cf-dicey-app-v3 DOMAIN -n HOSTNAME
  ```
  
0.  Consult the App Heath dashboard, notice:
  * `cf-dicey-app-v3` has less `503` errors, 
  * and a better 95th percentile response time. 
  * <img width="1671" alt="screen shot 2015-07-17 at 07 27 14" src="https://cloud.githubusercontent.com/assets/227505/8741815/3aa42e0c-2c56-11e5-98f7-9beba69b08a9.png">
  * Hurrah!
  
0. Complete the migration of traffic from v1 to v3
  ```
  cf scale cf-dicey-app-v3 -i 5
  sleep 30
  cf delete cf-dicey-app-v1 -f
  ```

## Discussion

1.  How did PCF enable zero downtime deployment?
2.  How does ELK-for-PCF allow us to answer the question: "Is v2 operationally better than v1"?
