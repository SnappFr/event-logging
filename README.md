# EventLogging

Plugin for event logging in rails application.

Read our article[https://medium.com/snapp-fr/event-logging-b509b275f80f] (sorry French only)

## Installation

Add this line to your application's Gemfile :

```ruby
  gem 'event_logging', git: 'git@github.com:Snapp-FidMe/event-logging.git', branch: :master
```
Import migrations with :

```bash
  bundle exec event_logging:install:migrations
```

Require Rails 5. or later and Postgresql with jsonb (9.6 or greater).

## Tests

Configure database in test/dummy/config/database.yml then play migrations :

```bash
  RAILS_ENV=test bundle exec rake db:migrate
```

And launch tests :

```bash
  bundle exec rake test
```

## Event

Events carry this data :

* stream_id => Write model ID
* aggregate_name => Model name
* action => operation which raised event (create, update, destroy or custom)
* created_at
* payload => hash that contains model changes

## Write models

Write models are business logic models. Use the Writer concern :

```ruby
  class Reward < ApplicationRecord
    include EventLogging::Writer

    # Business stuff
  end
```

Then after each create or update an event will be inserted in database, and associated read models will have to manage the event.

All the process is in callback transaction so data will be consistent over exceptions.

Write model can dispatch custom events :

```ruby
  reward.dispatch_event_log!('custom_action', 'the' => 'payload')
```

## Read models

Read models are data projection. Use the Reader concern :

```ruby
 class RewardLog < ApplicationRecord
   include EventLogging::Reader

   register_write_models :reward, :retailer

   class << self
     def handle_event_log(event)
       if event.aggregate_name == Reward.name
         handle_reward_event_log(event)
       elsif event.aggregate_name == Retailer.name
         handle_retailer_event_log(event)
       end
     end

     def handle_reward_event_log(event)
       if event.action == 'create'
         RewardLog.create!(
           reward_id: event.stream_id,
           status: event.payload['status'][1],
           retailer_id: event.payload['retailer_id'][1]
           retailer_name: Retailer.find(event.payload['retailer_id'][1]).name
         )
       elsif event.action == 'update' && event.payload.has_key?['status']
         reward = Reward.find(event.stream_id)
         RewardLog.create!(
           reward_id: event.stream_id,
           status: event.payload['status'][1],
           retailer_id: reward.retailer.id
           retailer_name: reward.retailer.name
         )
       end
     end

     def handle_retailer_event_log(event)
       if event.payload.has_key?('name')
         Reward.where(retailer_id: event.stream_id).find_each do |reward|
           reward.update_attributes!(retailer_name: event.payload['name'][1])
         end
       end
     end
   end
 end
```

Default payload is saved_changes from Rails.

Be careful : synchronised read models slow write operations in order to speed up read operations.
