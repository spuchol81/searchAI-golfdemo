---
slug: dashboard-discover-j8rwre
id: jxxo8efvgdix
type: challenge
title: Create the Airline decision dashboard
teaser: Find the best company with dashboard and discover
notes:
- type: text
  contents: |
    # ⛳ Caddie your large language model

    ## Welcome

    This is an interactive workshop where you’ll build a conversational experience on top of data hosted inside Elastic
    ---

    ## ▶️ How to Navigate

    * For  <span style="color: #00bfb3; font-weight: bold;">the full workshop experience</span> , <span style="color: #f04e99; font-weight: bold;">please use the  <img src="../assets/Jan-09-2026_at_15.46.59-image.png" style="display: inline; margin: 0; height: 50px; vertical-align: middle;"> button on the right of the screen </span> to navigate through the introductory content, even if the <img src="../assets/Jan-10-2026_at_11.45.53-image.png" style="display: inline; margin: 0; height: 50px; vertical-align: middle;"> button is flashing. Be sure to <span style="color: #00bfb3;; font-weight: bold;">review all the material proposed</span> <span style="color: #f04e99; font-weight: bold;">between each challenges</span>
    * Click the right-hand arrow now to see the workshop dataset and introduction video.


    ---
    ## ⚠️ Disclaimer
    > The dataset used in this scenario relates to airline operations ✈️<br>
    > All data and scenarios in this workshop are <span style="color: #fec514; font-weight: bold;">purely fictional</span> and created for learning purposes only,
    >  they <span style="color: #fec514; font-weight: bold;">do not reflect real airline performance or operations</span>
- type: text
  contents: '![img01.png](../assets/img01.png)'
- type: text
  contents: <video src="../assets/golfv2.mp4" controls></video>
tabs:
- id: e7ipwls4pfey
  title: Dataset
  type: service
  hostname: kubernetes-vm
  path: /app/discover#
  port: 30001
  custom_request_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
  custom_response_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
- id: avat7kaed95i
  title: Dashboard list
  type: service
  hostname: kubernetes-vm
  path: /app/dashboards#/list?_g=(filters:!(),refreshInterval:(pause:!t,value:60000),time:(from:now-7d,to:now))&s=Flights
  port: 30001
  custom_request_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
  custom_response_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["e7ipwls4pfey","avat7kaed95i"],"activeTabId":"e7ipwls4pfey","size":69}},{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":30}}],"orientation":"Horizontal"}}'
enhanced_loading: null
---
What you will do during this challenge
===
Before diving into how giving your LLM proper tool to navigate the course of your enterprise data, you will :
1. Take a tour on the workshop's dataset
2. Create views to graphically surface information and help customer choose the best airline for their next trip

Take a tour on the workshop's dataset
===
Let's have a look to the use case's [button label="Dataset"](tab-0).
Data has been ingested for you in two separated indices:
- ![Jan-10-2026_at_10.49.42-image.png](../assets/Jan-10-2026_at_10.49.42-image.png) gathering flights facts like airports, travel conditions and delays
-  ![Jan-10-2026_at_10.48.31-image.png](../assets/Jan-10-2026_at_10.48.31-image.png)gathering the airlines user's comments and rating of their flight experience

Create Airline review dashboard
===
1. Let's switch to [button label="dashboards list "](tab-1)
2. click on the Flights dashboard
3. Click the edit button![A02-editdash.png](../assets/A02-editdash.png)
4. Click on Add button and select >New Panel > ES|QL ![A02-addpanel.png](../assets/A02-addpanel.png)
5. Copy and paste the below ES|QL query in the configuration form. Click Run Query > Apply and Close
```
FROM airline_reviews
| KEEP `Airline Name`, Review
```
5.  Save the dashboard
![Jan-10-2026_at_10.07.40-image.png](../assets/Jan-10-2026_at_10.07.40-image.png)

Filter stats and reviews to focus on specific airline
===
Copy and paste the below KQL query in the search bar and Click Update
![A02-KQL.png](../assets/A02-KQL.png)
```
Carrier :"Lufthansa" or Airline Name :"Lufthansa"
```
What you have done during this challenge
===
You now have a combined view with Airline delay stats and customer review to decide if Lufthansa is a good company for your next trip !
![Jan-10-2026_at_10.10.42-image.png](../assets/Jan-10-2026_at_10.10.42-image.png)

> [!NOTE]
>Not really easy to dig into this amount of information right?
>During the next challenge, you will use the summarization power of LLM with agent builder to chat with your data in natural language and get those insights instantly!


