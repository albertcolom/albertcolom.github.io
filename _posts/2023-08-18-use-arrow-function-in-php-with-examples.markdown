---
title: "Use Arrow Function in PHP with examples"
layout: post
date: 2023-08-18 00:00
image: https://miro.medium.com/v2/resize:fit:640/format:webp/1*MZ8q2lwR54p9UOXPR2Vy3g.png
headerImage: false
tag:
- PHP
- closures
category: blog
author: albertcolom
description: It is available since PHP version 7.4 but many do not understand how to use it.
---

![Markdowm Image](https://miro.medium.com/v2/resize:fit:640/format:webp/1*MZ8q2lwR54p9UOXPR2Vy3g.png)

It is available since PHP version 7.4 but many do not understand how to use it.

Arrow functions, also known as “`short closures`”, were introduced in PHP 7.4 as a more concise way to define anonymous functions. They are particularly useful for small, simple functions.

Probably if you come from other languages you are already used to using them but if this is not your case I encourage you to continue reading the article where I show you some examples of use.

### How to use Arrow Function

Arrow functions are defined using the `fn` keyword, followed by the function parameters, the arrow (`=>`) symbol, and the function body.

Here we can see a basic example of how to implement it.

{% highlight php %}
// Anonymous function
$add = function($a, $b) {
    return $a + $b;
};

// Arrow function
$addArrow = fn($a, $b) => $a + $b;

echo $add(2, 3);        // Output: 5
echo $addArrow(2, 3);   // Output: 5
{% endhighlight %}

Arrow functions can also capture variables from the surrounding scope, unlike traditional closures, arrow functions do not need to be explicitly defined variables from scope.

{% highlight php %}
$factor = 10;

// Closure
$multiplier = function($n) use ($factor) {
    return $n * $factor;
};

// Arrow function
$multiplierArrow = fn($n) => $n * $factor;

echo $multiplier(5);        // Output: 50
echo $multiplierArrow(5);   // Output: 50
{% endhighlight %}

### Examples

Now that we have seen how to define an arrow function in PHP, let’s see some examples of how to use them.

In the examples we can see that both the traditional anonymous function and the arrow function achieve the same result.

#### Using Arrow Functions in Array Map

They square each number in the input array using the [`array_map`](https://www.php.net/manual/en/function.array-map.php){:target="_blank"} function.

_“Applies the callback to the elements of the given arrays”_

> array_map(?[callable](https://www.php.net/manual/en/language.types.callable.php){:target="_blank"} `$callback`, array `$array`, array `...$arrays`): array

{% highlight php %}
$numbers = [1, 2, 3, 4, 5];

// Anonymous function with array_map
$squared = array_map(function($n) {
    return $n * $n;
}, $numbers);

// Arrow function with array_map
$squaredArrow = array_map(fn($n) => $n * $n, $numbers);

print_r($squared);
print_r($squaredArrow);

// Output:
//Array
//(
//  [0] => 1
//  [1] => 4
//  [2] => 9
//  [3] => 16
//  [4] => 25
//)
//Array
//(
//  [0] => 1
//  [1] => 4
//  [2] => 9
//  [3] => 16
//  [4] => 25
//)
{% endhighlight %}

#### Using Arrow Functions with Array Filter

We filter all the even numbers of an array using the [`array_filter`](https://www.php.net/manual/en/function.array-filter.php){:target="_blank"} function.  
Filters elements of an array using a callback function

“_Filters elements of an array using a callback function_”

> array_filter(array `$array`, ?[callable](https://www.php.net/manual/en/language.types.callable.php){:target="_blank"} `$callback` = null, int `$mode` = 0): array

{% highlight php %}
$numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// Anonymous function with array_filter
$evenNumbers = array_filter($numbers, function($n) {
    return $n % 2 === 0;
});

// Arrow function with array_filter
$evenNumbersArrow = array_filter($numbers, fn($n) => $n % 2 === 0);

print_r($evenNumbers);
print_r($evenNumbersArrow);

// Output:
//Array
//(
//  [1] => 2
//  [3] => 4
//  [5] => 6
//  [7] => 8
//  [9] => 10
//)
//Array
//(
//  [1] => 2
//  [3] => 4
//  [5] => 6
//  [7] => 8
//  [9] => 10
//)
{% endhighlight %}

#### Using Arrow Functions with Array Reduce

We sum all values in array with callback function using the [`array_reduce`](https://www.php.net/manual/en/function.array-filter.php){:target="_blank"} function.

_“Iteratively reduce the array to a single value using a callback function”_

> array_reduce(array `$array`, [callable](https://www.php.net/manual/en/language.types.callable.php){:target="_blank"} `$callback`, mixed `$initial` = null): mixed

{% highlight php %}
$numbers = [1, 2, 3, 4, 5];

// Anonymous function with array_reduce
$sumNumbers = array_reduce($numbers, function($carry, $number) {
    return $carry + $number;
}, 0);

// Arrow function with array_reduce
$sumNumbersArrow = array_reduce($numbers, fn($carry, $number) => $carry + $number, 0);

echo $sumNumbers;       // Output: 15
echo $sumNumbersArrow;  // Output: 15
{% endhighlight %}

#### Using Arrow Functions with usort

Arrow functions can be used in various contexts, including callbacks for array by reference functions like [`usort`](https://www.php.net/manual/en/function.usort.php){:target="_blank"}. Sort the array by age.

_“Sort an array by values using a user-defined comparison function”_

> usort(array `&$array`, [callable](https://www.php.net/manual/en/language.types.callable.php){:target="_blank"} `$callback`): true

{% highlight php %}
$people = [
    ['name' => 'Alice', 'age' => 28],
    ['name' => 'Bob', 'age' => 22],
    ['name' => 'Charlie', 'age' => 25],
];

// Sorting using usort with anonymous function
usort($people, function($a, $b) {
    return $a['age'] <=> $b['age'];
});

// Sorting using arrow function
usort($people, fn($a, $b) => $a['age'] <=> $b['age']);

print_r($people);

// Output:
//Array
//(
//  [0] => Array
//      (
//          [name] => Bob
//          [age] => 22
//      )
//
//  [1] => Array
//      (
//          [name] => Charlie
//          [age] => 25
//      )
//
//  [2] => Array
//    (
//      [name] => Alice
//      [age] => 28
//    )
//
//)
{% endhighlight %}

I think that with these examples we can see how to implement the arrow functions in the most common cases.

If you think that I have left some or you have some doubt about some case, leave me a comment :-)

### Conclusion

Arrow functions were introduced in PHP 7.4 as a more concise way to define anonymous functions. They offer several advantages, but also have some limitations. Here are the pros and cons of using arrow functions in PHP:

#### Pros:

- **Concise Syntax** : Arrow functions have a more compact syntax compared to traditional closures, which can make your code cleaner and more readable, especially for simple operations.
- **Less Boilerplate** : Arrow functions eliminate the need for writing the function keyword and curly braces, reducing the amount of boilerplate code.
- **Implicit Return** : Arrow functions have an implicit return, meaning that the result of the expression is automatically returned without needing a return statement.
- **Short-lived Functions** : Arrow functions are particularly useful for short-lived functions used in higher-order functions like array functions (e.g., array\_map, array\_filter, array\_reduce) and callbacks.

#### Cons:

- **Limited Scope** : Arrow functions have a limited scope and cannot be used to modify variables outside their scope. They don’t support the use keyword to capture variables from the surrounding scope.
- **Single Expression** : Arrow functions are limited to a single expression. They cannot contain multiple statements or complex logic. For more complex functions, you’ll still need to use traditional closures.
- **Readability for Complex Logic** : While arrow functions can improve code readability for simple operations, they might make more complex logic harder to understand. Traditional closures might be more appropriate in such cases.
- **Compatibility** : Arrow functions were introduced in PHP 7.4. If you need to maintain compatibility with older PHP versions, you cannot use arrow functions.

#### Choosing Between Arrow Functions and Traditional Closures:

- Use arrow functions for simple operations that fit within a single expression and don’t require modifying variables from the surrounding scope.
- Use traditional closures when you need more complex logic, multiple statements, or need to capture variables from the surrounding scope.
- Consider the overall readability and maintainability of your code when deciding whether to use arrow functions or traditional closures.

In summary, arrow functions can be a powerful tool for writing concise and readable code for simple operations. However, it’s important to be aware of their limitations and choose the appropriate tool based on the specific context and complexity of your code.

You can read the article on [Medium](https://medium.com/@albertcolom/how-to-use-arrow-function-in-php-c28490ff7fb7){:target="_blank"}
