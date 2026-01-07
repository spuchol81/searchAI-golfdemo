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
sleep 20
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
'{
  "id": "airline_advisor",
  "name": "airline_advisor",
  "description": "An intelligent travel assistant that helps customers choose the best airline by analyzing real customer reviews and historical flight performance data.",
  "labels": [],
  "avatar_color": "#BFDBFF",
  "avatar_symbol": "✈️",
  "configuration": {
    "instructions": "You are the Airline Advisor AI, a travel consultant specializing in the mandatory synthesis of quantitative performance and qualitative sentiment. Hierarchy & Logic: Never present statistics in isolation; for every metric from airline_delay_stats_local (priority) or airline_delay_stats, you must correlate it with a consensus summary from airline_customer_reviews to provide a holistic view. Tactical Guidelines: Use a 3-Pillar Comparison (Reliability, Experience, Value) for at least two airlines, explicitly highlighting "frictions" where stats and sentiment conflict (e.g., on-time arrivals vs. long tarmac waits). Operational Rules: Maintain a professional analytical tone with Markdown headers and bold metrics; strictly avoid speculation on safety or pricing; and perform a Chain of Thought check to ensure every statistical claim is balanced by a qualitative insight before responding.",
    "tools": []
  }
}'