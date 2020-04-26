1. Widget是什么

   官方解释：Widgets describe what their view should look like given their current configuration and state.

   Widget是用于对视图样式的配置信息及其状态的描述。

   View, ViewController, Activity, Application, Layout等在Flutter中都是Widget

   一切皆是Widget

2. 响应式编程范式

   是一种基于“数据流”模型的声明式编程范式

   * 命令式：将命令下达到每一个具体的步骤，精确的告诉操作系统要做什么，强调精确控制过程细节（原生iOS和Android）

     过程：创建并添加view -> 收到事件 -> 获取需要更改的view -> 修改view对应的属性

   ```swift
   // 声明
   let label = UILabel()
   label.text = "first"
   ...
   // 修改
   label.text = "second"
   ```

   * 声明式：直接声明预期的结果，程序自己完成中间的步骤，强调通过意图输出结果整体（Flutter，Rx）

     过程：创建view并绑定数据 -> 收到事件 -> 修改数据

   ```dart
   // 声明
   var text = "first";
   Text(text);
   ...
   // 修改
   setSate() {
     text = "second"
   }
   ```

   设计思想：视图和数据分离，通过数据的修改驱动视图的变化

   基于响应式的设计思想，不希望直接操作view，所以通过view通过读取Widget的描述信息来响应变化

3. Widget如何构建UI

   Flutter把视图的组织和渲染抽象为三个部分：Widget、Element和RenderObject

   三部分都以树的方式进行组织，分别构成了Widget树、Element树和RenderObject树

   * Widget存储了有关视图渲染的配置信息，包括布局、渲染属性、事件响应信息等。它被设计为不可变的，想要改变它需要重建
   * Element是Widget的一个实例化对象，它承载了视图构建的上下文数据，连接了结构化的配置信息Widget和实施最终渲染的RenderObject
   * RenderObject负责视图的渲染

4. Widget、Element、RenderObject之间有什么关系？

5. StatelessWidget与StatefulWidget之间的区别，为什么需要有这两种区分

6. 为什么需要State，setState()如何实现页面刷新

7. runApp()之后发生了什么，UI是如何被渲染到屏幕上的

8. Flutter为什么能够达到native级的渲染速度

