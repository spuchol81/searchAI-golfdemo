####################################################################### ENV

ENV_FILE_PARENT_DIR=/home/kubernetes-vm
ENV_FILE=$ENV_FILE_PARENT_DIR/env
export $(cat $ENV_FILE | xargs)

####################################################################### OPENAI

# Activate Agent builder
curl -u "elastic:changeme" -H "Content-Type: application/json" -H "kbn-xsrf: true" -H "x-elastic-internal-origin: Kibana" -XPOST "http://kubernetes-vm:30001/internal/kibana/settings" -d \
'{
   "changes": {
      "agentBuilder:enabled": true
   }
}'

# Deploy kibana flights sample dataset 
curl -u "elastic:changeme" -H "Content-Type: application/json" -H "kbn-xsrf: true" -H "x-elastic-internal-origin: Kibana" -XPOST "http://kubernetes-vm:30001/api/sample_data/flights"

# Patch dataset with real companies
curl -H "Authorization: ApiKey $ELASTICSEARCH_APIKEY" -H "Content-Type: application/json" -XPOST "http://elasticsearch-es-http.default.svc:9200/kibana_sample_data_flights/_update_by_query" -d \
'{
  "script": {
    "source": "ctx._source.Carrier = params.new_value",
    "lang": "painless",
    "params": {
      "new_value": "Air France"
    }
  },
  "query": {
    "term": {
      "Carrier": "ES-Air"
    }
  }
}'

curl -H "Authorization: ApiKey $ELASTICSEARCH_APIKEY" -H "Content-Type: application/json" -XPOST "http://elasticsearch-es-http.default.svc:9200/kibana_sample_data_flights/_update_by_query" -d \
'{
  "script": {
    "source": "ctx._source.Carrier = params.new_value",
    "lang": "painless",
    "params": {
      "new_value": "Aeroflot Russian Airlines"
    }
  },
  "query": {
    "term": {
      "Carrier": "JetBeats"
    }
  }
}'

curl -H "Authorization: ApiKey $ELASTICSEARCH_APIKEY" -H "Content-Type: application/json" -XPOST "http://elasticsearch-es-http.default.svc:9200/kibana_sample_data_flights/_update_by_query" -d \
'{
  "script": {
    "source": "ctx._source.Carrier = params.new_value",
    "lang": "painless",
    "params": {
      "new_value": "Lufthansa"
    }
  },
  "query": {
    "term": {
      "Carrier": "Logstash Airways"
    }
  }
}'

#Prepare index to ingest customer review dataset from Kaggle
curl -H "Authorization: ApiKey $ELASTICSEARCH_APIKEY" -H "Content-Type: application/json" -XPUT "http://elasticsearch-es-http.default.svc:9200/airline_reviews" -d \
'{
    "mappings": {
              "properties": {
        "Aircraft": {
          "type": "text"
        },
        "Airline Name": {
          "type": "keyword"
        },
        "Cabin Staff Service": {
          "type": "long"
        },
        "Date Flown": {
          "type": "keyword"
        },
        "Food & Beverages": {
          "type": "long"
        },
        "Ground Service": {
          "type": "long"
        },
        "Inflight Entertainment": {
          "type": "long"
        },
        "Overall_Rating": {
          "type": "long"
        },
        "Recommended": {
          "type": "keyword"
        },
        "Review": {
          "type": "text",
          "copy_to":[
            "Review_semantic"
          ]
        },
        "Review Date": {
          "type": "keyword"
        },
        "Review_Title": {
          "type": "text"
        },
        "Review_semantic": {
          "type": "semantic_text",
          "inference_id": ".elser-2-elasticsearch",
          "model_settings": {
            "service": "elasticsearch",
            "task_type": "sparse_embedding"
          }
        },
        "Route": {
          "type": "text"
        },
        "Seat Comfort": {
          "type": "long"
        },
        "Seat Type": {
          "type": "keyword"
        },
        "Type Of Traveller": {
          "type": "keyword"
        },
        "Value For Money": {
          "type": "long"
        },
        "Verified": {
          "type": "keyword"
        },
        "Wifi & Connectivity": {
          "type": "long"
        }
      }
    }
}'

# Ingest review dataset
curl -H "Authorization: ApiKey $ELASTICSEARCH_APIKEY" -H "Content-Type: application/x-ndjson" --data-binary "@searchAI-golfdemo/data/Airline_reviews.ndjson" -XPOST "http://elasticsearch-es-http.default.svc:9200/airline_reviews/_bulk"

# Create data view
curl -u "elastic:changeme" -H "Content-Type: application/json" -H "kbn-xsrf: true" -H "x-elastic-internal-origin: Kibana" -XPOST "http://kubernetes-vm:30001/api/data_views/data_view" -d \
'{
  "data_view": {
    "id": "airline_reviews",
    "name": "airline_reviews",
    "title": "airline_reviews"
  }
}'

# Configure AI connector with gtp-4o
/opt/workshops/elastic-llm.sh -k false

# Add Airline agent with no tools
curl -u "elastic:changeme" -H "Content-Type: application/json" -H "kbn-xsrf: true" -H "x-elastic-internal-origin: Kibana" -XPOST "http://kubernetes-vm:30001/api/agent_builder/agents" -d \
'   {
      "id": "airline_advisor",
      "name": "airline_advisor",
      "description": "An intelligent travel assistant that helps customers choose the best airline by analyzing real customer reviews and historical flight performance data. ",
      "labels": [],
      "avatar_color": "#BFDBFF",
      "avatar_symbol": "✈️",
      "configuration": {
        "instructions": """You are an Airline Advisor AI that helps customers choose airlines, compare options, and evaluate reliability using tool-based evidence.

Tools

You may have access to:

airline_customer_reviews

airline_delay_stats

airline_delay_airport_selector

airline_delay_stats_local

Global Rules

Always support answers with customer reviews.

Follow the Delay Rules when handling punctuality, delays, or connection-risk questions.

No unsupported speculation.

Maintain a neutral, concise, helpful tone.

Format all responses in Markdown.

Delay Rules (Priority Logic)
1. If ONLY airline_customer_reviews is available

Use reviews only to answer delay/on-time questions.

Clarify that only qualitative review data is available.

2. If airline_customer_reviews + airline_delay_stats are available

Use both:

Quantitative delay metrics from airline_delay_stats

Review sentiment from airline_customer_reviews

3. If airline_customer_reviews + airline_delay_airport_selector + airline_delay_stats_local are available

For any delay question:

Use airline_delay_airport_selector to get the nearest airport ID.

Use airline_delay_stats_local  and do not use airline_delay_stats as the local stats are more relevant for the user

Behavior

Tailor responses to the user’s stated priorities (price, comfort, reliability, amenities, loyalty programs).

Provide clear pros/cons when comparing airlines.

Do not provide legal, medical, or safety advice beyond general travel service guidance.

Output

Use Markdown, with tables or lists when helpful.""",
        "tools": [
        ]
      }
   }'
