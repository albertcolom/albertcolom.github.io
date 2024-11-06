---
title: "Use custom PHP Collection instead Array"
layout: post
date: 2023-08-15 00:00
image: https://miro.medium.com/v2/resize:fit:1206/format:webp/1*Tc6XAkhz9ewQq8W5XTwsLQ.png
headerImage: false
tag:
- PHP 
category: blog
author: albertcolom
description: In this article we will see how to define a custom PHP collection.
#externalLink: https://medium.com/@skolom_93361/how-to-publish-domain-events-with-doctrine-listener-f48a8a18681d
---

![Array vs Collection](https://miro.medium.com/v2/resize:fit:1206/format:webp/1*Tc6XAkhz9ewQq8W5XTwsLQ.png)

In this article we will see how to define a custom PHP collection

An **Array** is a basic data structure that stores values key/value without any constrictions or any OOP method and it is very difficult to control and maintain the data they contain.

To solve this problem some modern frameworks like [Laravel](https://laravel.com/){:target="_blank"} ([Illuminate Collection](https://laravel.com/docs/master/collections){:target="_blank"}) or [Symfony](https://symfony.com/){:target="_blank"} ([Doctrine ArrayCollection](https://www.doctrine-project.org/projects/doctrine-collections/en/latest/index.html){:target="_blank"}) use their own OOP wrapper with a lot of functions.

But if we want to decouple from the framework or we use another framework and do not want to install the dependency we can create our own collection.

In this article, we will see how to build our own collection with some methods to work with objects. In the example, it is focused on a CQRS architecture and we place the collection in the reading layer.

**NOTE:** *In the code examples we have used PHP 8.1 but the code is fully adaptable to any other version.*

## Custom collection:
Firstly create a custom collection without type validation and add some callable functions `fromMap, reduce, map, each, some, filter` and other OOP functions like `first, last, count, isEmpty, add, values, items, getIterator` . This is the base of OOP wrapper for working with arrays.

> src/Shared/Domain/Read/Collection.php

```php
<?php

declare(strict_types=1);

namespace App\Shared\Domain\Read;

use ArrayIterator;
use IteratorAggregate;
use Traversable;

abstract class Collection implements IteratorAggregate
{
    public function __construct(private array $elements)
    {
    }

    public static function createEmpty(): static
    {
        return new static([]);
    }

    public static function fromMap(array $items, callable $fn): static
    {
        return new static(array_map($fn, $items));
    }

    public function reduce(callable $fn, mixed $initial): mixed
    {
        return array_reduce($this->elements, $fn, $initial);
    }

    public function map(callable $fn): array
    {
        return array_map($fn, $this->elements);
    }

    public function each(callable $fn): void
    {
        array_walk($this->elements, $fn);
    }

    public function some(callable $fn): bool
    {
        foreach ($this->elements as $index => $element) {
            if ($fn($element, $index, $this->elements)) {
                return true;
            }
        }

        return false;
    }

    public function filter(callable $fn): static
    {
        return new static(array_filter($this->elements, $fn, ARRAY_FILTER_USE_BOTH));
    }

    public function first(): mixed
    {
        return reset($this->elements);
    }

    public function last(): mixed
    {
        return end($this->elements);
    }

    public function count(): int
    {
        return count($this->elements);
    }

    public function isEmpty(): bool
    {
        return empty($this->elements);
    }

    public function add(mixed $element): void
    {
        $this->elements[] = $element;
    }

    public function values(): array
    {
        return array_values($this->elements);
    }

    public function items(): array
    {
        return $this->elements;
    }

    public function getIterator(): Traversable
    {
        return new ArrayIterator($this->elements);
    }
}
```

## Custom typed Collection:
The typed collection extends the above collection and implements the constraints.

**NOTE:** *To avoid creating more code than necessary I have used the `webmozzart/assert` ([pakagist](https://packagist.org/packages/webmozart/assert){:target="_blank"}) library but feel free to implement your validations.*

> src/Shared/Domain/Read/TypedCollection.php

```php
<?php

declare(strict_types=1);

namespace App\Shared\Domain\Read;

use Webmozart\Assert\Assert;

abstract class TypedCollection extends Collection
{
    public function __construct(array $elements = [])
    {
        Assert::allIsInstanceOf($elements, $this->type());

        parent::__construct($elements);
    }

    abstract protected function type(): string;

    public function add(mixed $element): void
    {
        Assert::isInstanceOf($element, $this->type());

        parent::add($element);
    }
}
```

## Example implement Typed Collection:
First of all, we need a create a basic Entity Class, in this case create a simple class called `Foo`.

```php
<?php

declare(strict_types=1);

namespace App\Context\Foo\Domain\Read\View\Foo;

final readonly class Foo
{
    public function __construct(
        public string $id,
        public string $name
    ) {
    }

    public function toArray(): return
    {
        return [
          'id' => $this->id,
          'name' => $this->name,
        ];
    }

    public function equals(self $other): bool
    {
        return $this->id === $other->id && $this->name === $other->name;
    }
}
```

Then can create a typed collection that contain a Foo inside

> src/Context/Foo/Domain/Read/View/FooCollection.php

```php
<?php

declare(strict_types=1);

namespace App\Context\Foo\Domain\Read\View;

use App\Shared\Domain\Read\TypedCollection;

final class FooCollection extends TypedCollection
{
    protected function type(): string
    {
        return Foo::class;
    }
}
```

## Some examples of how to use it
Create an empty collection, then add two `Foo` elements and filter elements with `other` name:

```php
$collection = FooCollection::createEmpty();
$collection->add(new Foo('4dae0971-ac81-43f1-b7e1-952df598af5a', 'name'));
$collection->add(new Foo('42deac29-9661-47e8-8746-062fc784ae1b', 'other'));

# Filter by name "other"

$filteredCollection = $collection->filter(function(Foo $foo) {
    return $foo->mame === 'other';
});

# Or if you prefer you can use Arrow function version

$filteredCollection = $collection->filter(fn (Foo $foo) => $foo->mame === 'other');
```

Create collection from map function using array :

```php
$array = [
  [
    'id' => '4dae0971-ac81-43f1-b7e1-952df598af5a',
    'name' => 'name',
    'surname' => 'surname',
  ],
  [
    'id' => '42deac29-9661-47e8-8746-062fc784ae1b',
    'name' => 'other',
  ],
];

# Create fromMap

$collection = FooCollection::fromMap($array, function(array $data){
    return new Foo($data['id'], $data['name'])
});


# Or if you prefer you can use Arrow function version

$collection = FooCollection::fromMap(
    $array,
    fn(array $data): Foo => new Foo($data['id'], $data['name'])
);
```

Concat different function with arrow functions:

```php
$array = [
  [
    'id' => '4dae0971-ac81-43f1-b7e1-952df598af5a',
    'name' => 'name',
    'surname' => 'surname',
  ],
  [
    'id' => '42deac29-9661-47e8-8746-062fc784ae1b',
    'name' => 'other',
  ],
];

# Create a collection from map, then filter by name and finally return array

$collection = FooCollection::fromMap(
    $array,
    fn(array $data): Foo => new Foo($data['id'], $data['name'])
)
->filter(fn (Foo $foo) => $foo->mame === 'other')
->map(fn (Foo $foo) => $foo->toArray());
```

You can read the article on [Medium](https://medium.com/@albertcolom/use-custom-php-collection-instead-array-57700858cf1a){:target="_blank"}
