---
title: "Publish domain events with doctrine listener"
layout: post
date: 2023-08-01 00:00
image: https://miro.medium.com/v2/resize:fit:4800/format:webp/1*xcmyZnE7xxZnvGQHacH-sw.png
headerImage: false
tag:
- PHP
- symfony
- doctrine
- DDD
category: blog
author: albertcolom
description: Publish domain events on the Queue system when Doctrine flush entity using clean architectures.
#externalLink: https://medium.com/@skolom_93361/how-to-publish-domain-events-with-doctrine-listener-f48a8a18681d
---

![Markdowm Image](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*xcmyZnE7xxZnvGQHacH-sw.png)

Publish domain events on the Queue system when Doctrine flush entity using clean architectures.

## In this example, we use:
- [Symfony](https://symfony.com/){:target="_blank"} as PHP framework
- [Symfony Messenger](https://symfony.com/doc/current/components/messenger.html){:target="_blank"} as EventBus
- [Doctrine](https://www.doctrine-project.org/){:target="_blank"} as ORM
- [RabbitMQ](https://www.rabbitmq.com/){:target="_blank"} as Message broker

## Create DomainEvent Entity
First of all, create an abstract Entity of which they will inherit all domain events. This entity will be placed on a shared domain as it will be used in different contexts and of this example it will be placed in the writing layer as we implement CQRS.

> src/Shared/Domain/Write/Event/DomainEvent.php

{% highlight php %}
<?php

declare(strict_types=1);

namespace App\Shared\Domain\Write\Event;

use DateTimeImmutable;

abstract class DomainEvent
{
    private const DATE_FORMAT = 'Y-m-d H:i:s';

    public function __construct(private ?string $occurredOn = null)
    {
        $this->occurredOn = $occurredOn ?? (new DateTimeImmutable())->format(self::DATE_FORMAT);
    }

    public function occurredOn(): string
    {
        return $this->occurredOn;
    }
}
{% endhighlight %}

### Create AggregateRoot Entity
Create an abstract class called `AggregateRoot` witch inherit all root entities.
The `AggregateRoot` is used to define the main entity from aggregate and can store on memory and publish the domain events from the entity.

> src/Shared/Domain/Write/Aggregate/AggregateRoot.php

{% highlight php %}
<?php

declare(strict_types=1);

namespace App\Shared\Domain\Write\Aggregate;

use App\Shared\Domain\Write\Event\DomainEvent;

abstract class AggregateRoot
{
    private array $domainEvents = [];

    final protected function recordEvent(DomainEvent $domainEvent): void
    {
        $this->domainEvents[] = $domainEvent;
    }

    final public function domainEventsEmpty(): bool
    {
        return empty($this->domainEvents);
    }

    final public function pullDomainEvents(): array
    {
        $recordedEvents = $this->domainEvents;
        $this->domainEvents = [];

        return $recordedEvents;
    }
}
{% endhighlight %}


And create a simple root entity to use which uses the above class and record an event when construct.
Firstly create a simple Event like a DTO called `FooWasCreated.

> src/Context/Foo/Domain/Write/Event/FooWasCreated.php

{% highlight php %}
<?php

declare(strict_types=1);

namespace App\Context\Foo\Domain\Write\Event;

use App\Shared\Domain\Write\Event\DomainEvent;

final class FooWasCreated extends DomainEvent
{
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public readonly string $createdAt,
        ?string $occurredOn = null
    ) {
        parent::__construct($occurredOn);
    }
}
{% endhighlight %}

Then can create a root entity to record the event and store it in memory when construct the entity.

> src/Context/Foo/Domain/Write/Foo.php

{% highlight php %}
<?php

declare(strict_types=1);

namespace App\Context\Foo\Domain\Write;

use App\Context\Foo\Domain\Write\Event\FooWasCreated;
use App\Shared\Domain\Write\Aggregate\AggregateRoot;
use DateTimeImmutable;

final class Foo extends AggregateRoot
{
    public function __construct(
        private string $id,
        private string $name,
        private DateTimeImmutable $createdAt
    ) {
        $this->recordEvent(
            new FooWasCreated($id, $name, $createdAt->format('Y-m-d H:i:s'))
        );
    }

    public function id(): string
    {
        return $this->id;
    }

    public function name(): string
    {
        return $this->name;
    }

    public function createdAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
}
{% endhighlight %}

**NOTE:** *This entity must define as Doctrine mapping because when persist this entity trigger the events. In this example not define doctrine infrastructure layer to persist the entity, I think you can find a lot of tutorials about that and I don't want to make this tutorial longer.*

### Define bus for events with messenger
Define the interface on a shared domain in the write layer.

> src/Shared/Domain/Write/Bus/EventBus.php

{% highlight php %}
<?php

declare(strict_types=1);

namespace App\Shared\Domain\Write\Bus\Event;

use App\Shared\Domain\Write\Event\DomainEvent;

interface EventBus
{
    public function publish(DomainEvent ...$domainEvents): void;
}
{% endhighlight %}

Implement the interface with the concrete Symfony Messenger on the infrastructure layer. This bus is quite simple just has one method `publish` is responsible for dispatching messages on `MessageBus`.

> src/Shared/Infrastructure/Bus/MessengerEventBus.php

{% highlight php %}
<?php

declare(strict_types=1);

namespace App\Shared\Infrastructure\Bus;

use App\Shared\Domain\Write\Bus\EventBus;
use App\Shared\Domain\Write\Event\DomainEvent;
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Messenger\Stamp\DispatchAfterCurrentBusStamp;

final readonly class MessengerEventBus implements EventBus
{
    public function __construct(private MessageBusInterface $messageBus)
    {
    }

    public function publish(DomainEvent ...$domainEvents): void
    {
        foreach ($domainEvents as $currentEvent) {
            $this->messageBus->dispatch(
                (new Envelope($currentEvent))->with(new DispatchAfterCurrentBusStamp())
            );
        }
    }
}
{% endhighlight %}

Define Bus service messenger on `messenger.yaml` in this example define `async` bus to publish events on the `ampqp` transport with RabbitMQ.

In this case, we use `ampqp` because no need other dependences than Symfony Messenger but you can define other transports like a `kafka`.

**NOTE:** *You can find more information on: <https://symfony.com/doc/current/messenger.html#transports-async-queued-messages>*

> .env

{% highlight bash %}
MESSENGER_TRANSPORT_DSN=amqp://guest:guest@rabbitmq:5672/%2f/messag
{% endhighlight %}

> config/packages/messenger.yaml

To simplify the example I just define de basic configuration of the event bus but you should define the other bus like a query or command and the correct retry policy.

{% highlight yaml %}
framework:
    messenger:
        transports:
            ampqp:
                dsn: '%env(MESSENGER_TRANSPORT_DSN)%'
        buses:
            async.event.bus:
                default_middleware: allow_no_handlers
        routing:
            'App\Shared\Domain\Write\Event\DomainEvent': ampqp
{% endhighlight %}

> config/services.yaml

To simplify this example I just defined the minimum services definition for this case but you need to define your different services need for your application.

{% highlight yaml %}
parameters:

services:
    _defaults:
        autowire: true
        autoconfigure: true

    App\:
        resource: '../src/'

    App\Shared\Infrastructure\Bus\MessengerEventBus:
        arguments:
            - '@async.event.bus'
{% endhighlight %}

## Create Doctrine Listener to publish DomainEvents when flush
The idea is quite simple when flush the entity the listener gets the entities to update from Doctrine `UnitOfWork and publish the domain events if they have.

Once the events are published Symfony Messenger takes care of sending the Queue system.

{% highlight php %}
<?php

declare(strict_types=1);

namespace App\Shared\Infrastructure\Listener;

use App\Shared\Domain\Write\Bus\Event\EventBus;
use App\Shared\Domain\Write\Aggregate\AggregateRoot;
use Doctrine\ORM\Event\OnFlushEventArgs;

final readonly class DoctrinePublishDomainEventsOnFlushListener
{
    public function __construct(private EventBus $eventBus)
    {
    }

    public function onFlush(OnFlushEventArgs $eventArgs): void
    {
        $unitOfWork = $eventArgs->getObjectManager()->getUnitOfWork();

        foreach ($unitOfWork->getScheduledEntityInsertions() as $entity) {
            $this->publishDomainEvent($entity);
        }

        foreach ($unitOfWork->getScheduledEntityUpdates() as $entity) {
            $this->publishDomainEvent($entity);
        }

        foreach ($unitOfWork->getScheduledEntityDeletions() as $entity) {
            $this->publishDomainEvent($entity);
        }

        foreach ($unitOfWork->getScheduledCollectionDeletions() as $collection) {
            foreach ($collection as $entity) {
                $this->publishDomainEvent($entity);
            }
        }

        foreach ($unitOfWork->getScheduledCollectionUpdates() as $collection) {
            foreach ($collection as $entity) {
                $this->publishDomainEvent($entity);
            }
        }
    }

    private function publishDomainEvent(object $entity): void
    {
        if ($entity instanceof AggregateRoot && !$entity->domainEventsEmpty()) {
            $this->eventBus->publish(...$entity->pullDomainEvents());
        }
    }
}
{% endhighlight %}

And define the listener on a service definition.

> config/services.yaml

{% highlight yaml %}
parameters:

services:
    _defaults:
        autowire: true
        autoconfigure: true

    App\:
        resource: '../src/'

    App\Shared\Infrastructure\Bus\MessengerEventBus:
        arguments:
            - '@async.event.bus'

    App\Shared\Infrastructure\Listener\DoctrinePublishDomainEventsOnFlushListener:
            tags:
                - { name: doctrine.event_listener, event: onFlush }
{% endhighlight %}

**NOTE:** *You can find more doctrine events on: <https://www.doctrine-project.org/projects/doctrine-orm/en/2.15/reference/events.html#events-overview>*

## Conclusion
In this example, you can see how to implement an EventBus with Symfony Messenger and implement doctrine listener to publish domain events on flush at RabbitMQ following clean architectures.

You can read the article on [Medium](https://medium.com/@albertcolom/how-to-publish-domain-events-with-doctrine-listener-f48a8a18681d){:target="_blank"}
