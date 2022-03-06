# Lock
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
### NSLock、NSRecursiveLock、NSCondition
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
* NSRecursiveLock 是对 mutex 递归锁的封装，API 跟 NSLock 基本一致 
* NSCondition 是对 mutex 和 cond 的封装
```objc
@interface NSCondition : NSObject <NSLocking> 

- (void)wait;
- (BOOL)waitUnitlDate:(NSDate *)limit;
- (void)signal;
- (void)broadcast;

@end
```
### dispatch_semaphore
### dispatch_queue(DISPATCH_QUEUE_SERIAL)
### NSLock
### NSRecursiveLock
### NSCondition
### NSConditionLock
### @synchronized