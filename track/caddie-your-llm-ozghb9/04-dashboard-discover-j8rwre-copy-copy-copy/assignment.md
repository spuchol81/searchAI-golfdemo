---
slug: dashboard-discover-j8rwre-copy-copy-copy
id: 2x95jgyt8sbf
type: challenge
title: Adjust flight data statistics to only what matters
teaser: Refine the dataset to only reflect your domestic airport
notes:
- type: text
  contents: '  ![Jan-03-2026_at_12.10.35-image.png](../assets/Jan-03-2026_at_12.10.35-image.png)'
- type: text
  contents: '![Jan-03-2026_at_12.10.52-image.png](../assets/Jan-03-2026_at_12.10.52-image.png)'
tabs:
- id: p81auhin9zck
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
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["p81auhin9zck"],"activeTabId":"p81auhin9zck","size":78}},{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":20}}],"orientation":"Horizontal"}}'
enhanced_loading: null
---
What you will do during this challenge
===
You will upgrade your customer experience by releasing a new version of your agent :
1. Creating a tool  able to get the customer domestic's airport of the flight history dataset based on the customer location
2. Creating a tool to get the delay statistics out of flight history dataset, filtered regarding the customer's domestic airport
3. Assigning these tools to the airline advisor agent. He will use it to enrich his context and confirm customer reviews he already has access to
4. Chat with him about airline advices

Create airline_delay_airport_selector tool
===
1. Click on the Manage tools button ![Jan-10-2026_at_10.33.43-image.png](../assets/Jan-10-2026_at_10.33.43-image.png)
2. Add a new tool ![A03-newtool.png](../assets/A03-newtool.png)

 Use the following  Parameters

[button label="Tool ID"]()
```
airline_delay_airport_selector
```

[button label="Description"]()
```
a query to check the nearest airport for the customer
```

[button label="ES|QL Query"]()
```
FROM kibana_sample_data_flights
		| EVAL distancekmAirport = ST_DISTANCE(OriginLocation , TO_GEOPOINT(?coordinate))/1000
		| SORT distancekmAirport ASC
		| KEEP OriginAirportID
		| limit 1
```

Click on infer parameter to automagically populate the list of parameters with **?coordinates** and define it as follows
[button label="description"]()
```
the coordinates in the WKT format ie POINT(`longitude` `latitude`)
```

[button label="type"]()
```
text
```
Click Save

Create airline_delay_stats_local tool
===
1. Add a new tool ![A03-newtool.png](../assets/A03-newtool.png)

 Use the following  Parameters

[button label="Tool ID"]()
```
airline_delay_stats_local
```

[button label="Description"]()
```
A query to get all the delays by Carriers on a specific airport. to be used in conjonction with the result of `airline_delay_airport_selector`
```

[button label="ES|QL Query"]()
```
FROM kibana_sample_data_flights
		| where FlightDelay : true  and FlightDelayType: "Carrier Delay" and (OriginAirportID: ?AirportID or DestAirportID: ?AirportID)
		| STATS  cumulated_delay = SUM(FlightDelayMin) by Carrier
		| SORT cumulated_delay DESC
		| limit 10
```

Click on infer parameter to automagically populate the list of parameters with **?AirportID** and define it as follows
[button label="description"]()
```
the airport code found with the bushnell
```

[button label="type"]()
```
text
```
Click Save
![Jan-10-2026_at_10.55.01-image.png](../assets/Jan-10-2026_at_10.55.01-image.png)

Click on Agent builder on top left to come back to main menu

Assign both tools to airline advisor agent
===
1. Click on the Manage agents button ![Jan-10-2026_at_10.58.21-image.png](../assets/Jan-10-2026_at_10.58.21-image.png)
2. Edit airline_advisor agent by clicking the pen button appearing near the three dots when you hover it ![Jan-10-2026_at_10.25.31-image.png](../assets/Jan-10-2026_at_10.25.31-image.png)
3. In tools tab check the airline_delay_airport_selector and airline_delay_stats_local tool.
![Jan-10-2026_at_11.12.56-image.png](../assets/Jan-10-2026_at_11.12.56-image.png)
5. You should have now a total of 4 tools to be used by the agent
![Jan-10-2026_at_11.13.20-image.png](../assets/Jan-10-2026_at_11.13.20-image.png)
7. Click Save

Chat with airline advisor agent
===
Click chat button near the three dots on the airline_advisor agent line when you hover it

Ask the following question to the agent
```
	I don't want to be late, I'm starting from Lavaur, France. What is the best company?
```
the agent will answer you based on the customer reviews and airline real past performance for your domestic airport only (check it by dropping down the reasoning section)
![Jan-10-2026_at_11.15.45-image.png](../assets/Jan-10-2026_at_11.15.45-image.png)
> [!WARNING]
> Content shown is generated dynamically and may differ across interactions.


What you have done during this challenge
===
After adding these final tools to the airline advisor agent, you now have the most accurate answer:
- based on real customer experience
- confirmed by statistics and real data
- adjusted to your local specifics

And all of this is done just by asking in natural language! No complex searches or filters required!

> [!NOTE]
> Congratulations! You just learned how to be the perfect caddy for your LLM, giving him tools to get context on your enterprise data
![Jan-03-2026_at_12.38.39-image.png](../assets/Jan-03-2026_at_12.38.39-image.png)
