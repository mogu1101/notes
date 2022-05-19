# Crash
### 常见 crash 类型
* OC 层面 crash
  * 普通类型
    * `NSInvalidArgumentException`：非法参数异常，传入非法参数导致异常，nil 参数比较常见。
    * `NSRangeException`：下标越界导致的异常
    * `NSGenericException`： foreach的循环当中修改元素导致的异常。 
  * KVO 导致的 crash
    * 移除未注册的观察者
    * 重复移除观察者
    * 添加了观察者但是没有实现 `-observeValueForKeyPath:ofObject:change:context:` 方法
    * 添加移除keypath=nil
    * 添加移除observer=nil
  * unrecognized selector sent to instance
* Signal 层面 crash
  * `SIGKILL`：用来立即结束程序运行的信号。
  * `SIGSEGV`：试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据。
  * `SIGABRT`：调用abort函数生成的信号。
  * `SIGTRAP`：由断点指令或其它trap指令产生。
  * `SIGBUS`：非法地址, 包括内存地址对齐(alignment)出错。比如访问一个四个字长的整数, 但其地址不是4的倍数。它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。
