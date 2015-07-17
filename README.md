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
cf map-route APP DOMAIN -n HOSTNAME
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

## Deploy v2
0.  Looking at the App Health dashboard, note how v1 of the app has 2 operation issues.
   * Returns `503` errors ~ 5% of the time
   * Has a 95th percentile response time of 4s
0.  