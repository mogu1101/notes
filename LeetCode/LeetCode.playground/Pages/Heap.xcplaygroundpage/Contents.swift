import Foundation

class MaxHeap: NSObject {
    private var maxSize = 8
    private var realSize = 0
    private var heap: [Int] = []
    
    override init() {
        super.init()
        heap = [Int](repeating: 0, count: 8)
    }

    func add(_ value: Int) {
        realSize += 1
        if realSize == maxSize {
            heap.append(contentsOf: [Int](repeating: 0, count: maxSize))
            maxSize = heap.count
        }
        heap[realSize] = value
        var index = realSize
        var parent = index / 2
        while heap[index] > heap[parent], index > 1 {
            (heap[index], heap[parent]) = (heap[parent], heap[index])
            index = parent
            parent = index / 2
        }
    }
    
    func pop() -> Int {
        if realSize < 1 { return Int.min }
        let value = heap[1]
        swap(&heap[realSize], &heap[1])
        realSize -= 1
        var index = 1
        while index < realSize && index <= realSize / 2 {
            let left = index * 2
            let right = index * 2 + 1
            if heap[left] > heap[right] {
                (heap[left], heap[index]) = (heap[index], heap[left])
                index = left
            } else {
                (heap[index], heap[right]) = (heap[right], heap[index])
                index = right
            }
        }
        return value
    }
    
    var peek: Int { heap[1] }
    
    var size: Int { realSize }
    
    override var description: String {
        return "\([Int](heap[1...realSize]))"
    }
}

print("123")

let heap = MaxHeap()
heap.add(5)
heap.add(10)
heap.add(3)
heap.add(1)
heap.add(5)
heap.add(9)
heap.add(8)
heap.add(2)
heap.add(4)

print(heap)
