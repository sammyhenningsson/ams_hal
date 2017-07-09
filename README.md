# ams_hal

ActiveModelSerializers is really neat when it comes to serializing resources. However it lacks support for [HAL](http://stateless.co/hal_specification.html).
This Gem makes it possible to represent resources as HAL with ActiveModelSerializers serializers.


## Installation

Add these lines to your application's Gemfile:

```
gem 'active_model_serializers', '~> 0.10.2'
gem 'ams_hal', '~>0.2.0'
```

And then execute:

```
$ bundle
```

Configure the adapter (e.g. in an initializer such as `config/initializers/active_model_serializers.rb`)

``` ruby
ActiveModelSerializers.config.adapter = AmsHal::Adapter
```

## Using the ams_hal adapter

Your serializers will look pretty much that same as any normal ActiveModelSerializer. For example:
``` ruby
class PostSerializer < ActiveModel::Serializer
  attributes :title, :message
  
  link :author do
    users_path object
  end
  
  has_many :comments
end
```
Which would be serialized into somthing like:
``` ruby
{
    "_embedded": {
        "comments": [
            {
                "text": "some important comments"
            },
            {
                "text": "more comments"
            }
        ]
    },
    "_links": {
        "author": {
            "href": "https://example.com/users/1"
        }
    },
    "message": "lorem ipsum..",
    "title": "hello"
}
```
The associations `belongs_to` and `has_one` may also be used. These nested resources will get serialized using
a serializer found by the normal serializer lookup. If you would like to specify a certain serializer then
write
``` ruby
has_many :comments, serializer: MySerializer`
```
Note: some things, e.g. type and meta, are not support in HAL. Unsupported attributes will be ignored by the ams_hal adapter.   

One cool thing about having the serializers written as any other AMS serializer is that you can choose between HAL, JSON_API, etc on per request basis. This means that you can be really reastful and let the clients choose how the response should be represented. If you add something like this in your ApplicationController:
``` ruby
class ApplicationController < ActionController::API

  DEFAULT_ADAPTER = AmsHal::Adapter

  def render(options = nil, extra_options = {}, &block)
    return super if options[:adapter]
    accept = request.headers['Accept']
    if accept.present? && accept =~ %r(application/vnd.api\+json)
      options[:adapter] = :json_api
      options[:content_type] = "application/vnd.api+json"
    else
      options[:adapter] = DEFAULT_ADAPTER
      options[:content_type] = "application/hal+json"
    end

    super(options, extra_options, &block)
  end
end
```
Then a client that sends requests with the `Accept` header set to `application/hal+json` would be served HAL resources, while another client that sets the `Accept` header to `application/vnd.api+json` would be served JSON API.

## HAL only
If you don't plan on serving any other media types and want to go all in with HAL, then include AmsHal::Curies and AmsHal::Embedded in your serializeres. You will then get a nice DSL so that you can write your serializer like this:
``` ruby
class PostHALSerializer < ActiveModel::Serializer
    include AmsHal::Embedded
    include AmsHal::Curies

    attributes :title, :message

    link :author do
      "https://example.com/users/1"
    end

    embed :comments do
      object.comments
    end

    curie :doc do
      "http://example.com/docs/{rel}"
    end
  end
```
Which would be serialized into somthing like:

``` ruby
{
    "_embedded": {
        "comments": [
            {
                "text": "some important comments"
            },
            {
                "text": "more comments"
            }
        ]
    },
    "_links": {
        "author": {
            "href": "https://example.com/users/1"
        },
        "curies": [
            {
                "href": "http://example.com/docs/{rel}",
                "name": "doc",
                "templated": true
            }
        ]
    },
    "message": "lorem ipsum..",
    "title": "hello"
}
```
Like associations, the nested resources will get serialized using a serializer found by the normal serializer lookup.
(I.e. a resource of class `Comment` will use the serializer `CommentSerializer`). If you would like to specify a certain
serializer then write
``` ruby
embed :comments, serializer: MySerializer
```

