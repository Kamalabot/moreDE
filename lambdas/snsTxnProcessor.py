{ 
   "Comment":"Transaction Processor State Machine Using SNS",
   "StartAt":"ProcessTransaction",
   "States":{ 
      "ProcessTransaction":{ 
         "Type":"Pass",
         "Next":"BroadcastToSns"
      },
      "BroadcastToSns":{ 
         "Type":"Task",
         "Resource":"arn:aws:states:::sns:publish",
         "Parameters":{ 
            "TopicArn":"Replace Me!",
            "Message":{ 
               "TransactionId.$":"$.TransactionId",
               "Type.$":"$.Type",
               "Source": "Step Functions!"
            }
         },
      "End":true
      }
   }
}
