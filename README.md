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

## Using the adapter

Your serializers should look pretty much that same as any normal ActiveModelSerializer. For example:
``` ruby
class PostSerializer < ActiveModel::Serializer
  attributes :title, :message
  
  link :author do
    users_path object
  end
  
  has_many :comments
end
```
Which would return:
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
write `has_many :comments, serializer: MySerializer`.
Some things, such as type and meta, are not support in HAL.  

This makes it possible to let the client request application/hal+json or application/vnd.api+json and 
use the same serializers. E.g. adding this to the ApplicationController:
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
Please note: The Accept header can be quiet complex and this maybe not be the best way to dynamically select the media type.

## HAL only
If you want to go all in with HAL, then include AmsHal::Curies and AmsHal::Embedded. Then write your serializer like:
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
Which would return:

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
(A resource of class `Comment` will use the serializer `CommentSerializer`). If you would like to specify a certain
serializer then write `embed :comments, serializer: MySerializer`.  

