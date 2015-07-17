# Blue/Green deployments: Is v2 better than v1?

This simple application demonstrates how the ELK-for-PCF tile gives operational insite into blue/green
deployments on Pivotal Cloud Foundry.

Specifically, it shows how the logs can be analysed in near real time during a zero downtime blue/green deployment
to evaluate whether v2 is operationally "better" than v1, to inform whether the deployment should be completed or rolled back.

## Setup

0. Clone this repository
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
  * 1/6th of the "production" traffic goes to cf-dicey-app-v2
  * cf-dicey-app-v2 actually has more `503` errors, and a worse 95th percentile response time!
0.  Abort the deploy
```
cf delete cf-dicey-app-v2 -f
```

## Deploy v3
0.  Edit `app.rb` and code up a "fix"
   * comment out line 10
   * uncomment line 11
0.  Start Blue/Green deploy
``
cf push cf-dicey-app-v3
cf map-route cf-dicey-app-v3 DOMAIN -n HOSTNAME
```
0.  Consult the App Heath dashboard, notice:
  * cf-dicey-app-v3 actually has less `503` errors, 
  * and a better 95th percentile response time.  
  * Hurrah!
0. Complete the migration of traffic from v1 to v3
```
cf scale cf-dicey-app-v3 -i 5
sleep 30
cf delete cf-dicey-app-v1 -f
```

## Discussion

1.  How did PCF's enable zero downtime deployment?
2.  How is ELK-for-PCF allow us to answer the question: "Is v2 operationally better than v1"?
