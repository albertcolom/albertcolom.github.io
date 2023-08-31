---
title: "Create your first Golang Lambda With Serverless Framework"
layout: post
date: 2023-08-29 00:00
image: https://miro.medium.com/v2/resize:fit:4800/format:webp/1*pNKc4T-lqOW1v17lYVUFjQ.png
headerImage: false
tag:
- GO
- serverless
- lambda
category: blog
author: albertcolom
description: This article explains step-by-step how to implement a simple AWS Lambda with Serverless Framework.
---

![Markdowm Image](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*pNKc4T-lqOW1v17lYVUFjQ.png)

This article explains step-by-step how to implement a simple AWS Lambda with _Serverless Framework_.

#### Prerequisites to follow this article

- [AWS account](https://aws.amazon.com/){:target="_blank"}
- [aws-cli](https://aws.amazon.com/cli/){:target="_blank"} with the property permissions
- [Node.js](https://nodejs.org/){:target="_blank"} to use _Serverless Framework_
- [Go](https://go.dev/){:target="_blank"}

#### Why use a AWS lambda?

[AWS Lambda](https://aws.amazon.com/lambda/){:target="_blank"} is a serverless computing service provided by Amazon Web Services (AWS). It allows you to run your code in response to events without needing to provision or manage servers. With AWS Lambda, you can focus solely on writing your application code while AWS takes care of the infrastructure and scaling for you.

#### Pros

- **Cost:** You only pay for the compute time your functions consume. There’s no need to pay for idle server resources, making it cost-effective for applications with varying workloads.
- **Auto-Scaling** : Lambda automatically scales your code to handle incoming requests or events. It can run thousands of instances of your function in parallel.
- **Stateless** : Lambda functions are designed to be stateless, meaning they don’t retain memory between invocations. You can use external storage services for persistent data.

#### Const

- **Cold Start Latency** : Cold starts occur when a function is invoked after being idle for a period of time. Cold starts can introduce latency in your application, which might not be suitable for all use cases.
- **Limitations:** Lambda functions have a maximum execution time limit and have predefined resource limits (CPU, memory) that might not be sufficient for certain applications.

#### Why use a AWS Serverless Framework?

The [_Serverless Framework_](https://www.serverless.com/){:target="_blank"} is a tool written in Node that simplifies the deployment and management of serverless applications and functions. It abstracts away many of the complexities involved in setting up and configuring serverless services like AWS Lambda, API Gateway, and others.

### Get Started

#### Step 1: **Install Serverless Framework**

Open your terminal and run the following command to install the _Serverless Framework_ globally:

{% highlight bash %}
npm install -g serverless
{% endhighlight %}

**_NOTE_** _: If you type_ _`serverless` in the terminal you can choose a template to generate a skeleton of the project._

![](https://cdn-images-1.medium.com/max/660/1*tMwp92kN5AJ8QbFupJSM9w.png)
_Serverless crete skeleton project_

#### Step 2: Create simple Health Checks in Go

Create a directory from the project and initialize a Golang project.

**_NOTE_** _: Feel free to change the name of the project._

{% highlight bash %}
mkdir GoServerless

cd GoServerless

go mod init go-lambda-serverless
{% endhighlight %}

Finally, create your `main.go` with a simple health check.

{% highlight go %}
package main

import (
 "context"
 "github.com/aws/aws-lambda-go/events"
 "github.com/aws/aws-lambda-go/lambda"
)

type Response events.APIGatewayProxyResponse

func Handler(ctx context.Context, request events.LambdaFunctionURLRequest) (Response, error) {
 return Response{Body: "It works!", StatusCode: 200}, nil
}

func main() {
 lambda.Start(Handler)
}
{% endhighlight %}

Then install all dependencies

{% highlight bash %}
go mod tidy
{% endhighlight %}

#### Step 3: Compile de project

{% highlight bash %}
env GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -o bin/health main.go
{% endhighlight %}

#### Step 4: Create a Serverless config file

Create _`serverless.yml`_ on the root project with the content:

{% highlight yaml %}
service: go-serverless # Define your service name

provider:
  name: aws
  runtime: go1.x
  region: eu-central-1 # Put your AWS region

package:
  patterns:
    - '!./**'
    - ./bin/**

functions:
  health:
    handler: bin/health # route to binary
    events:
      - http:
          path: /health
          method: get
          cors: true
          private: false
{% endhighlight %}

**_NOTE_** _: You can find the all information on the oficial documentation:_ [_https://www.serverless.com/framework/docs/providers/aws/guide/serverless.yml_](https://www.serverless.com/framework/docs/providers/aws/guide/serverless.yml){:target="_blank"}

#### Step 5: Deploy!

Thanks to the _Serverless framework_ it is very easy to deploy any application, just `serverless deploy` on the console and the magic happens :-)

{% highlight bash %}
serverless deploy
{% endhighlight %}

**_NOTE_** _: If you get more information about the deploy you can add_ _`--verbose parameter`._

![](https://cdn-images-1.medium.com/max/1024/1*EZKEb5uxupkzo17ZOArwqQ.png)
_Serverless deploy output_

**And thats all!** the framework takes the responsibility to create the necessary infrastructure on AWS and return the URL to the defined endpoint.

You can try the endpoint by [CURL](https://curl.se/){:target="_blank"}

{% highlight bash %}
curl -X GET https://jqlar1r8pd.execute-api.eu-central-1.amazonaws.com/dev/health
{% endhighlight %}

Or if you prefer you can try via [Postman](https://www.postman.com/){:target="_blank"}

![](https://cdn-images-1.medium.com/max/1024/1*bQqw9mw5c7VTWBBSyDcvwA.png)
_Try the endpoint by postman_

You can also use the same _Serverless Framework_

{% highlight bash %}
serverless invoke -f health
{% endhighlight %}

![](https://cdn-images-1.medium.com/max/1024/1*BPozZoZwXamGnxElstKRZQ.png)
_Try the service by Serverless Framework_

#### Bonus

You can remove all the application incluiding teh infrastructure by de _Serverless Framework_.

{% highlight bash %}
serverless remove
{% endhighlight %}

![](https://cdn-images-1.medium.com/max/1024/1*u5XSEE08U4itb0URCbye1Q.png)

### Conclusion

In this article we have been able to see step by step how to create a very simple application with GO and deploy it using _Serverless Framework_, a great tool that makes our life much easier.

I did not pretend to make a very detailed article, I just wanted to show how to make a simple application from zero.

You can read the article on [Medium](https://medium.com/@albertcolom/how-to-create-your-first-golang-lambda-with-serverless-framework-d0c85120c647){:target="_blank"}
