# iOS 线程同步
### OSSpinLock
* 自旋锁，效率最高的锁
* 等待锁的线程会处于忙等状态，一直占用 CPU 资源
* 不安全，可能会出现线程优先级反转问题（iOS 10 以后废弃）
  * 如果优先级较低的线程先加锁，优先级较高的线程处于等待状态时，优先级较高的线程会一直占用 CPU 资源，导致优先级较低的加锁线程的无法分配到资源执行任务，从而导致锁无法被释放，造成类似于死锁的状态
* 需要导入头文件 ```#import <libkern/OSAtomic.h>```
```objc
// 初始化
OSSpinLock lock = OS_SPINLOCK_INIT;
// 尝试加锁（如果需要等待就不加锁，直接返回false；如果不需要等待就加锁，返回true
bool result = OSSpinLockTry(&lock);
// 加锁
OSSpinLockLock(&lock);
// 解锁
OSSpinLockUnlock(&lock);
```
<br>

### os_unfair_lock
* 用于取代不安全的 OSSpinLock ，从 iOS 10 开始支持
* 从底层调用看，等待 os_unfair_lock 锁的线程会处于休眠状态，并非忙等
* 需要导入头文件 ```#import <os/lock.h>```

```objc
// 初始化
os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
// 尝试加锁
os_unfair_lock_trylock(&lock);
// 加锁
os_unfair_lock_lock(&lock);
// 解锁
os_unfair_lock_unlock(&lock);
```
<br>

### pthread_mutex
* mutex 叫做“互斥锁”，等待锁的线程会处于休眠状态
* 需要导入头文件 ```#import <pthread.h>```

```objc
// 初始化锁的属性
pthread_mutexattr_t attr;
pthread_mutexattr_init(&attr);
pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
// 初始化锁
pthread_mutex_t mutex;
pthread_mutex_init(&mutex, &attr);
// 尝试加锁
pthread_mutex_trylock(&mutex);
// 加锁
pthread_mutex_lock(&mutex);
// 解锁
pthread_mutex_unlock(&mutex);
// 销毁相关资源
pthread_mutexattr_destroy(&attr);
pthread_mutex_destroy(&mutex);

// Mutex type attributes
#define PTHREAD_MUTEX_NORMAL        0
#define PTHREAD_MUTEX_ERRORCHECK    1
#define PTHREAD_MUTEX_RECURSIVE     2
#define PTHREAD_MUTEX_DEFAULT       PTHREAD_MUTEX_NORMAL
```

    递归锁：允许同一个线程对同一把锁进行重复加锁
    low-level lock：互斥锁：没等待解锁时就去休眠
    high-level lock：自旋锁：没等到解锁时会一直循环
<br>

* pthread_mutex - 条件
```objc
// 初始化锁
pthread_mutex_t mutex;
// NULL代表使用默认属性
pthread_mutex_init(&mutex, NULL);
// 初始化条件
pthread_cond_t condition;
pthread_cond_init(&condition, NULL);
// 等待条件（进入休眠，放开mutex锁；被唤醒后，会再次对mutex加锁）
pthread_cond_wait(&condition, &mutex);
// 激活一个等待该条件的线程
pthread_cond_signal(&condition);
// 激活所有等待该条件的线程
pthread_cond_broadcast(&condition);
// 销毁资源
pthread_mutex_destroy(&mutex);
pthread_cond_destroy(&condition);
```
<br>

### NSLock
* NSLock 是对 mutex 普通锁的封装

```objc
@interface NSLock : NSObject <NSLocking>

- (BOOL)tryLock;
- (BOOL)lockBeforeDate:(NSDate *)limit;

@end

@protocol NSLocking

- (void)lock;
- (void)unlock;

@end
```
<br>

### NSRecursiveLock
* NSRecursiveLock 是对 mutex 递归锁的封装，API 跟 NSLock 基本一致 
<br>

### NSCondition
* NSCondition 是对 mutex 和 cond 的封装
```objc
@interface NSCondition : NSObject <NSLocking> 

- (void)wait;
- (BOOL)waitUnitlDate:(NSDate *)limit;
- (void)signal;
- (void)broadcast;

@end
```
<br>

### NSConditionLock
* NSConditionLock 是对 NSCondition 的进一步封装，可以设置具体条件值
<br>

```objc
@interface NSConditionLock : NSObject <NSLocking>

@property (readonly) NSInteger condition;
- (instancetype)initWithCondition:(NSInteger)condition;
- (void)lockWhenCondition:(NSInteger)condition;
- (BOOL)tryLock;
- (BOOL)tryLockWhenCondition:(NSInteger)condition;
- (void)unlockWithCondition:(NSInteger)condition;
- (BOOL)lockBeforeDate:(NSDate *)limit;
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;

@end
```
<br>

### dispatch_queue(DISPATCH_QUEUE_SERIAL)
* 直接使用 GCD 的串行队列，也可以实现线程同步

<br>

### dispatch_semaphore
* 信号量的初始值，可以用来控制线程并发访问的最大数量
* 信号量的初始值为1，代表同时只允许1条线程访问资源，保证线程同步

```objc
// 信号量的初始值
int value = 1
// 初始化信号量
dispatch_semaphore_t semaphore = dispatch_semaphore_create(value);
// 如果信号量的值<=0，当前线程就会进入休眠等待（直到信号量的值>0）
// 如果信号量的值>0，就减1，然后往下执行后面的代码
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
// 让信号量的值加1
dispatch_semaphore_signal(semephore);
```
<br>

### @synchronized
* @synchronized 是对 mutex 递归锁的封装
* 源码查看：objc4 中的 objc-sync.mm 文件
* @synchronized(obj) 内部会生成 obj 对应的递归锁，然后进行加锁、解锁操作

```objc
@synchronized(obj) {
    // 任务
}
```
<br>

### 线程同步方案性能比较
性能从高到低：
  * os_unfair_lock
  * OSSpinLock
  * dispatch_semaphore
  * pthread_mutex
  * dispatch_queue(DISPATCH_QUEUE_SERIAL)
  * NSLock
  * NSCondition
  * pthread_mutex(recursive)
  * NSRecursiveLock
  * NSConditionLock
  * @synchronized

<br>

### 自旋锁、互斥锁比较
* 什么情况使用自旋锁比较划算？
  * 预计线程等待锁的时间很短
  * 加锁代码（临界区）经常被调用，但竞争情况很少发生
  * CPU 资源不紧张
  * 多核处理器

* 什么情况使用互斥锁比较划算？
  * 预计线程等待锁的时间很长
  * 单核处理器
  * 临界区有 IO 操作
  * 临界区代码复杂或者循环量大
  * 临界区竞争非常激烈
<br>

### atomic
* atomic 用于保证属性 setter、getter 的原子性操作，相当于在 getter 和 setter 内部加了线程同步的锁
* 可以参考源码 objc4 的 objc-accessors.mm
* 它并不能保证使用属性的过程中是线程安全的
* 消耗性能，所以平时开发中一般不用
<br>

### 读写安全方案
* 场景：多读单写
  * 同一时间，只能有1个线程进行写的操作
  * 同一时间，允许有多个线程进行读的操作
  * 同一时间，不允许既有些的操作，又有读的操作


* pthread_rwlock：等待的线程会进入休眠

    ```objc
    // 初始化锁
    pthread_rwlock_t lock;
    pthread_rwlock_init(&lock, NULL);
    // 读-加锁
    pthread_rwlock_rdlock(&lock);
    // 读-尝试加锁
    pthread_rwlock_tryrdlock(&lock);
    // 写-加锁
    pthread_rwlock_wrlock(&lock);
    // 写-尝试加锁
    pthread_rwlock_trywrlock(&lock);
    // 解锁
    pthread_rwlock_unlock(&lock);
    // 销毁
    pthread_rwlock_destroy(&lock);
    ```
* dispatch_barrier_async
  * 这个函数传入的并发队列必须是自己通过 dispatch_queue_create 创建的
  * 如果传入的是一个串行或是一个全局并发队列，那这个函数便等同于 dispatch_async 的效果

  ```objc
  // 初始化队列
  dispatch_queue_t queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);

  // 读
  dispatch_async(queue, ^{

  });

  // 写
  dispatch_barrier_async(queue, ^{

  });
  ```