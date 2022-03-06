# Flutter Layout
### Widget分类
* StatelessWidget：用于组合其他Widget，不可变
* StatefulWidget：用于组合其他Widget，可变
* InheritedWidget：用来在Widget树上做数据传递
* RenderObjectWidget：真正渲染到屏幕上，createRenderObject
    * LeafRenderObjectWidget
        * 没有子节点，如：Text、Image
    * SingleChildRenderObjectWidget
        * 只有一个子节点，有child属性
    * MultiChildRenderObjectWidget
        * 有多个子节点，有children属性

### 布局相关组件
https://flutterchina.club/widgets/layout/
* ##### SingleChildRenderObjectWidget
    Container、Padding、Center、Align、FittedBox、AspectRatio、ConstraintedBox、Baseline、FractionallySizedBox、IntrinsicHeight、IntrinsicWidth、LimitedBox、Offstage、OverflowBox、SizedBox、SizedOverflowBox、Transform、CustomSingleChildLayout
* ##### MultiChildRenderObjectWidget
    Row、Column、Stack、IndexedStack、Flow、Table、Wrap、ListBody、ListView、CustomMultiChildLayout
* ##### LayoutHelpers
    LayoutBuilder

### RenderObject
* 每个Element都对应一个RenderObject，RenderObject负责布局和绘制，所有RenderObject组成一颗渲染树Render Tree。
<br>
* RenderObjectWidget类中定义了创建、更新RenderObject的方法，子类必须实现他们
<br>
* RenderObject拥有一个parent和一个parentData，parent通过子RenderObject的parentData存储一些和子元素相关的信息，对子元素进行布局和绘制
<br>
* RenderObject实现了一套基础的layout和绘制协议，但是并没有定义子节点模型（如一个节点可以有几个子节点，没有子节点？一个？两个？或者更多？）。 它也没有定义坐标系统（如子节点定位是在笛卡尔坐标中还是极坐标？）和具体的布局协议（是通过宽高还是通过constraint和size?，或者是否由父节点在子节点布局之前或之后设置子节点的大小和位置等）。
<br>
* Flutter 提供了 RenderBox 和 RenderSliver 两个类继承了 RenderObject，RenderBox 用于盒模型布局，RenderSliver 用于按需加载的布局
<br>
* RenderBox 提供的主要方法
<br>
    ```dart
    // 初始化ParentData
  void setupParentData(covariant RenderObject child)

  // 计算宽高
  double getMinIntrinsicWidth(double height)
  double computeMinIntrinsicWidth(double height)
  double getMaxIntrinsicWidth(double height)
  double computeMaxIntrinsicWidth(double height)
  double getMinIntrinsicHeight(double width)
  double computeMinIntrinsicHeight(double width)
  double getMaxIntrinsicHeight(double width)
  double computeMaxIntrinsicHeight(double width)

  Size getDryLayout(BoxConstraints constraints)
  Size computeDryLayout(BoxConstraints constraints)
  bool get hasSize
  Size get size
  set size(Size value)
  double? getDistanceToBaseline(TextBaseline baseline, { bool onlyReal = false })
  double? getDistanceToActualBaseline(TextBaseline baseline)
  double? computeDistanceToActualBaseline(TextBaseline baseline)
  BoxConstraints get constraints => super.constraints as BoxConstraints;
  void markNeedsLayout() // 标记重新布局
  void performResize() // 可由子类实现，重新获取计算size
  void performLayout() // 子类实现布局方法

  // 点击测试
  bool hitTest(BoxHitTestResult result, { required Offset position })
  bool hitTestSelf(Offset position)
  bool hitTestChildren(BoxHitTestResult result, { required Offset position })

  void applyPaintTransform(RenderObject child, Matrix4 transform)
  Offset globalToLocal(Offset point, { RenderObject? ancestor })
  Offset localToGlobal(Offset point, { RenderObject? ancestor })
  Rect get paintBounds
  void handleEvent(PointerEvent event, BoxHitTestEntry entry)
    ```
<br>

### 布局过程
* #### Constraints
    在RenderBox 中，有个size属性用来保存控件的宽和高。RenderBox的layout是通过在组件树中从上往下传递BoxConstraints对象的实现的。BoxConstraints对象可以限制子节点的最大和最小宽高，子节点必须遵守父节点给定的限制条件。
<br>
    布局阶段，父节点会调用子节点的```layout()```方法，```RenderObject```中```layout()```方法的实现如下：
<br>
    ```dart
    void layout(Constraints constraints, {bool parentUsesSize = false}) {
        RenderObject? relayoutBoundary;

        // 先确定当前组件的布局边界
        if (!parentUsesSize ||
            sizedByParent ||
            constraints.isTight ||
            parent is! RenderObject) 
        {
            relayoutBoundary = this;
        } else {
            relayoutBoundary = (parent! as RenderObject)._relayoutBoundary;
        }
        // _needsLayout 表示当前组件是否被标记为需要布局
        // _constraints 是上次布局时父组件传递给当前组件的约束
        // _relayoutBoundary 为上次布局时当前组件的布局边界
        // 所以，当当前组件没有被标记为需要重新布局，且父组件传递的约束没有发生变化，
        // 且布局边界也没有发生变化时则不需要重新布局，直接返回即可。
        if (!_needsLayout && constraints == _constraints && relayoutBoundary == _relayoutBoundary) {    
            return;
        }
        // 如果需要布局，缓存约束和布局边界
        _constraints = constraints;
        _relayoutBoundary = relayoutBoundary;

        // 当前组件大小只取决于父组件约束，确定当前子组件大小逻辑抽离到performResize方法中
        if (sizedByParent) {
            performResize();
        }
        // 执行布局：对组件进行布局和确定子组件在当前组件中的位置
        performLayout();
        // 布局结束后将 _needsLayout 置为 false
        _needsLayout = false;
        // 将当前组件标记为需要重绘（因为布局发生变化后，需要重新绘制）
        markNeedsPaint();
    }
    ```
<br>

* #### RelayoutBoundary
    一个控件的大小被改变时可能会影响到它的 parent，因此 parent 也需要被重新布局,在```RenderObject```中的```markNeedsLayout()```方法会将```RenderObject```的布局状态标记为 dirty ，在下一个 frame 中进行重新布局，而在```layout()```方法中设置的```relayoutBoundary```会阻断向父级传递 relayout 的过程，如果当前```RenderObject```被标记为```relayoutBoundary```，就表示它的大小变化不会影响到 parent 的大小了， parent 就不用重新布局了
    <br>
    markNeedsLayout源码如下：
    <br>
    ```dart
    void markNeedsLayout() {
        ...
        assert(_relayoutBoundary != null);
        if (_relayoutBoundary != this) {
            markParentNeedsLayout();
        } else {
            _needsLayout = true;
            if (owner != null) {
                ...
                owner._nodesNeedingLayout.add(this);
                owner.requestVisualUpdate();
            }
        }
    }
    ```

    <!-- ![RelayoutBoundary](../images/RelayoutBoundary.png ) -->
    <div align = center>
        <img src="../images/RelayoutBoundary.png" width="600px">
    </div>

<br>

* #### performResize 和 performLayout
    * RenderBox实际的测量和布局逻辑是在performResize() 和 performLayout()两个方法中，RenderBox子类需要实现这两个方法来定制自身的布局逻辑。
    * ```performResize()```方法只有在```sizedByParent```为```true```时调用，```sizedByParent```表示该节点的大小是否仅通过 parent 传给它的 constraints 就可以确定了，即该节点的大小与它自身的属性和其子节点无关，此时大小在```performResize()```中就确定了，后面 layout 时无需修改
    * 在```performLayout()```方法中除了完成自身布局，也必须完成子节点的布局，这是因为只有父子节点全部完成后布局流程才算真正完成。所以最终的调用栈将会变成：```layout() > performResize()/performLayout() > child.layout() > ... ```，如此递归完成整个UI的布局。

<br>

### 约束、尺寸、位置
* 官网关于布局的解释
<br> 
    > <font color=#999999 size=3> “ 在进行布局的时候，Flutter 会以 DFS（深度优先遍历）方式遍历渲染树，并将限制以自上而下的方式 从父节点传递给子节点。子节点若要确定自己的大小，则必须遵循父节点传递的限制。子节点的响应方式是在父节点建立的约束内 将大小以自下而上的方式 传递给父节点。”</font>

<br>

* 向下传递约束，向上传递尺寸
<br>
* 紧约束：min constraints == max constraints
    Container、SizedBox
<br>
* 松约束：min constraints == 0
    Center、Align
<br>
* 无界：0 <= constraints <= Infinity
    UnconstraintedBox、ListView、Column、Row
<br>
* LayoutBuilder查看约束
<br>
* ConstraintedBox设置约束
<br>
### Container
* 布局原理
    * 没有child时会占满最大父级约束
        * 当父级约束是无界是container尺寸为0
    * 有child时会匹配child尺寸
        * 当child为Align时container会占满父级约束来确保child有位置可以对齐
<br>
* 组成
    * 当没有child且父级约束不是紧约束时
<br>
    ```dart
    if (child == null && (constraints == null || !constraints!.isTight)) {
      current = LimitedBox(
        maxWidth: 0.0,
        maxHeight: 0.0,
        child: ConstrainedBox(constraints: const BoxConstraints.expand()),
      );
    }
    ```
    * alignment => Align
    * padding、margin => Padding
    * color => ColoredBox
    * decoration、foregroundDecoration => DecoratedBox
    * width、height、constraints => ConstrainedBox
    * transform => Transform
    * clipBehavior => ClipPath
### Flex布局
* Column、Row都是继承自Flex
* 主轴参数：start、end、center、spaceBetween、spaceAround、spaceEvenly
* 交叉轴参数：start、end、center、stretch、baseline
* 布局原理：
    * 向下传递约束：假装自己是无界的，向下传递约束 0 <= constaints <= Infinity
    * 交叉轴尺寸：
        * stretch：拉伸到父级约束最大尺寸
        * 非stretch：根据最大子widget来确定
    * 主轴尺寸：
        * 布局无弹性的组件：确定各组件的尺寸，如果发现超过父级约束则越界
        * 布局flexible组件：按照份数平分剩下的尺寸
### Stack
* 布局原理：
    * 向下传递父级约束
    * 布局无位置组件：根据无位置组件中最大尺寸来确定stack尺寸，根据alignment属性来确定控件位置
    * 没有无位置组件时根据父级约束来确定stack尺寸
    * 布局有位置组件：以position参数为主，参考widget自身尺寸
    * 根据clipBehavior属性确定超出stack部分是否裁剪
### CustomMultiChildLayout
* 参数：
    * delegate: MultiChildLayoutDelegate
    * children
    * 通过实现MultiChildLayoutDelegate对children进行布局
<br>
* 实现MultiChildLayoutDelegate：
<br>
    ```dart
    /// 是否需要重新布局
    @override
    bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
    
    /// 布局children位置并获取children尺寸
    @override
    void performLayout(Size size) {
        List<Size> sizeList = List.generate(count, (index) => Size.zero);
        Size totalSize = Size.zero;
        for (var i = 0; i < count; i++) {
            // 根据childId判断child是否存在
            if (hasChild(i)) {
                // 布局child：向child传递约束，并获取其布局后的size
                sizeList[i] = layoutChild(i, BoxConstraints.loose(size));
                // 确定child位置
                positionChild(i, Offset(totalSize.width, totalSize.height));
                totalSize = Size(
                    totalSize.width + sizeList[i].width,
                    totalSize.height + sizeList[i].height,
                );
            }
        }
        
        // 判断最终布局是否越界
        if (totalSize.width > size.width) {
            print('宽度超出限制：${totalSize.width} > ${size.width}');
        }
        if (totalSize.height > size.height) {
            print('高度超出限制：${totalSize.height} > ${size.height}');
        }
    }
    ```
<br>

### 参考
<br>

[1] [《Flutter实战第二版》Flutter核心原理 - 布局（Layout）过程](https://book.flutterchina.club/chapter14/layout.html)

[2] [Flutter中文网 - 布局Widget](https://flutterchina.club/widgets/layout/)

[3] [Flutter布局（Layout）原理 系列视频](https://space.bilibili.com/589533168/channel/seriesdetail?sid=381994)

