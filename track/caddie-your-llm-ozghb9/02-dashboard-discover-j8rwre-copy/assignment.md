---
slug: dashboard-discover-j8rwre-copy
id: 2unm4b4hrqut
type: challenge
title: Access customer reviews  easily with hybrid search
teaser: Create a search tool for your LLM
notes:
- type: text
  contents: '![img03.png](../assets/img03.png)'
- type: text
  contents: '![img04.png](../assets/img04.png)'
- type: text
  contents: '![img02.png](../assets/img02.png)'
tabs:
- id: mq9xxvpn4b3p
  title: Agent builder
  type: service
  hostname: kubernetes-vm
  path: /app/agent_builder/conversations/new?agent_id=airline_advisor
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
  custom_layout: '{"root":{"children":[{"branch":{"size":71,"children":[{"leaf":{"tabs":["mq9xxvpn4b3p","eynpvvvlhplc"],"activeTabId":"eynpvvvlhplc","size":49}},{"leaf":{"tabs":["ynfma6gg1exy"],"activeTabId":"ynfma6gg1exy","size":49}}]}},{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":27}}],"orientation":"Horizontal"}}'
enhanced_loading: null
---
What you will do during this challenge
===
Now that you know the dataset you have to work with, you will
1. Create a tool to be able to get the most relevant customer reviews regarding a customer question
2. Assign this tool to the airline advisor agent. He will use it to enrich his context
3. Chat with him about airline advices

Create customer reviews analysis tool
===
1. Click on the Manage tools button ![Jan-10-2026_at_10.33.43-image.png](../assets/Jan-10-2026_at_10.33.43-image.png)
2. Add a new tool ![A03-newtool.png](../assets/A03-newtool.png)

 Use the following  Parameters

[button label="Tool ID"]()
```
airline_customer_reviews
```

[button label="Description"]()
```
A semantic search query to retrieve any relevant information un customer reviews
```

[button label="ES|QL Query"]()
```
FROM airline_reviews METADATA _score
    | WHERE MATCH(Review  , ?question, { "boost": 0.25 }) OR  MATCH(Review_semantic, ?question, { "boost": 0.75 })
    | SORT _score DESC
    | limit 50
```
 Click on infer parameter to automagically populate the list of parameters with **?question** and define it as follows

![A03-ESQLparams.png](../assets/A03-ESQLparams.png)

Click Save
![Jan-10-2026_at_10.35.32-image.png](../assets/Jan-10-2026_at_10.35.32-image.png)

Click on Agent builder on top left to come back to main menu
![Jan-10-2026_at_10.52.08-image.png](../assets/Jan-10-2026_at_10.52.08-image.png)

Assign customer reviews analysis tool to airline advisor agent
===
1. Click on the Manage agents button ![Jan-10-2026_at_10.58.21-image.png](../assets/Jan-10-2026_at_10.58.21-image.png)
2. Edit airline_advisor agent by clicking the pen button appearing near the three dots when you hover it![Jan-10-2026_at_10.25.31-image.png](../assets/Jan-10-2026_at_10.25.31-image.png)
3. In tools tab check the airline_customer_reviews tool
![Jan-10-2026_at_10.14.38-image.png](../assets/Jan-10-2026_at_10.14.38-image.png)
4. You should now have a total of 1 tool assigned to the agent
![Jan-10-2026_at_10.21.25-image.png](../assets/Jan-10-2026_at_10.21.25-image.png)
6. Click Save

Chat with airline advisor agent
===
1. Click chat button near the three dots on the airline_advisor agent line when you hover it
![Jan-10-2026_at_10.24.12-image.png](../assets/Jan-10-2026_at_10.24.12-image.png)
2. Ask the following question to the agent
```
	I don't want to be late,  what is the best company?
```
The agent will answer you based on the customer reviews

You can check his reasoning process and the tools he used by dropping down the arrow at the beginning of the answer
![Jan-03-2026_at_11.41.37-image.png](../assets/Jan-03-2026_at_11.41.37-image.png)
> [!WARNING]
> Content shown is generated dynamically and may differ across interactions.

What you have done during this challenge
===
Congratulations, you built an agent that has direct access to airline customers opinion. He can guide future customer in their airline choice based on past customers experience.
> [!NOTE]
> But Truth lives in the numbers! Let's confirm customer reviews with some statistics to get more accurate answer in the next challenge!