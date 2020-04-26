https://www.jianshu.com/p/f1fa7db28f7a

https://www.bookstack.cn/read/flutter-1.2-zh/dbc2f1806db39ad3.md

### 状态 State

```undefined
UI = f(state)
```

Flutter是描述性的, UI反映状态，状态的改变触发UI的重新绘制

### 状态分类

* **Ephemeral State**：短时状态，也称 UI状态 或者 局部状态

  * 可以完全包含在一个独立Widget中的状态；
  * widget 树中其他部分不需要访问这种状态；
  * 这种状态也不会以复杂的方式改变，不需要使用复杂的管理手段，只需要使用StatefulWidget进行管理

* **App State**：需要在很多地方共享的状态，也叫Shared State或者Global State

  * 用户登录，用户设置，通知，红点信息等；

* 这两种状态分类没有明确的界限划分，在一些简单的App里可以使用setState()来管理所有状态，在需要的时候，局部状态也可以被抽取到外部作为一个App State，一般状态的划分遵循以下原则：

<<<<<<< HEAD
  ![两种状态的区分规则](/Users/liujinjun/Documents/学习笔记/notes/images/两种状态的区分规则.png)
=======
  ![两种状态的区分规则](../images/两种状态的区分规则.png)
>>>>>>> ADD: 状态管理

  