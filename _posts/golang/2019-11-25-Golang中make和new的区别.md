---
layout: post
title: Golang中make和new的区别
categories: golang
---


# Golang中make和new的区别

## `new()` 

> 返回某类型的指针,值为该类型的零值

> new() Demo

```
package main

func main() {
	varint := new(int)
	println(varint, *varint)

	varstring := new(string)
	println(varstring, *varstring)

	varbool := new(bool)
	println(varbool, *varbool)
}

```

> 运行结果为,　可以看到new返回的是一个指针，该指针指向的值为该类型的默认值

```
0xc000046738 0
0xc000046740
0xc000046737 false
```

## `make()`

> 内建函数make(T, args)与new(T)的用途不一样。它只用来创建slice，map和channel，并且返回一个初始化的(而不是置零)，类型为T的值（而不是*T）。之所以有所不同，是因为这三个类型的背后引用了使用前必须初始化的数据结构。例如，slice是一个三元描述符，包含一个指向数据（在数组中）的指针，长度，以及容量，在这些项被初始化之前，slice都是nil的。对于slice，map和channel，make初始化这些内部数据结构，并准备好可用的值。

> make() demo

```
package main

import "fmt"

func main() {

	newslice := new([]int)
	fmt.Println(newslice)

	slice := make([]int, 5, 10)
	fmt.Println(slice)

	sliceString := make([]string, 5, 10)

	sliceString[1] = "b"
	fmt.Println(sliceString)

}

```

> 运行结果

```
&[]
[0 0 0 0 0]
[ b   ]
```
