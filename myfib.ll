; ModuleID = 'myfib.ll'
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n64-S128"
target triple = "riscv64-unknown-linux-gnu"

; 声明外部函数
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)
declare void @putf(ptr, ...)

; 字符串常量
@.str1 = private unnamed_addr constant [28 x i8] c"Enter the size of the array: \00", align 1
@.str2 = private unnamed_addr constant [20 x i8] c"Enter %d integers: \00", align 1
@.str3 = private unnamed_addr constant [17 x i8] c"Sum of evens: %d\0A\00", align 1

; is_even 函数定义
define i32 @is_even(i32 %num) {
entry:
  %mod = srem i32 %num, 2
  %cmp = icmp eq i32 %mod, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:
  ret i32 1

if.else:
  ret i32 0
}

; main 函数定义
define i32 @main() {
entry:
  ; 分配局部变量
  %n = alloca i32, align 4
  %sum = alloca i32, align 4
  %i = alloca i32, align 4
  %i2 = alloca i32, align 4
  
  ; 初始化 sum = 0
  store i32 0, ptr %sum, align 4
  
  ; 打印提示信息
  call void (ptr, ...) @putf(ptr @.str1)
  
  ; 读取数组大小
  %n_val = call i32 @getint()
  store i32 %n_val, ptr %n, align 4
  
  ; 动态分配数组
  %n_load = load i32, ptr %n, align 4
  %numbers = alloca i32, i32 %n_load, align 4
  
  ; 打印第二个提示信息
  %n_load2 = load i32, ptr %n, align 4
  call void (ptr, ...) @putf(ptr @.str2, i32 %n_load2)
  
  ; 第一个循环：读取数组元素
  store i32 0, ptr %i, align 4
  br label %for1.cond

for1.cond:
  %i_val = load i32, ptr %i, align 4
  %n_val2 = load i32, ptr %n, align 4
  %cmp1 = icmp slt i32 %i_val, %n_val2
  br i1 %cmp1, label %for1.body, label %for1.end

for1.body:
  ; numbers[i] = getint()
  %input = call i32 @getint()
  %i_val2 = load i32, ptr %i, align 4
  %arrayidx = getelementptr inbounds i32, ptr %numbers, i32 %i_val2
  store i32 %input, ptr %arrayidx, align 4
  
  ; i++
  %i_val3 = load i32, ptr %i, align 4
  %inc = add nsw i32 %i_val3, 1
  store i32 %inc, ptr %i, align 4
  br label %for1.cond

for1.end:
  ; 第二个循环：计算偶数和
  store i32 0, ptr %i2, align 4
  br label %for2.cond

for2.cond:
  %i2_val = load i32, ptr %i2, align 4
  %n_val3 = load i32, ptr %n, align 4
  %cmp2 = icmp slt i32 %i2_val, %n_val3
  br i1 %cmp2, label %for2.body, label %for2.end

for2.body:
  ; 获取 numbers[i] 的值
  %i2_val2 = load i32, ptr %i2, align 4
  %arrayidx2 = getelementptr inbounds i32, ptr %numbers, i32 %i2_val2
  %num_val = load i32, ptr %arrayidx2, align 4
  
  ; 调用 is_even 函数
  %is_even_result = call i32 @is_even(i32 %num_val)
  %is_even_bool = icmp ne i32 %is_even_result, 0
  br i1 %is_even_bool, label %if.add, label %if.skip

if.add:
  ; sum += numbers[i]
  %sum_val = load i32, ptr %sum, align 4
  %new_sum = add nsw i32 %sum_val, %num_val
  store i32 %new_sum, ptr %sum, align 4
  br label %if.skip

if.skip:
  ; i++
  %i2_val3 = load i32, ptr %i2, align 4
  %inc2 = add nsw i32 %i2_val3, 1
  store i32 %inc2, ptr %i2, align 4
  br label %for2.cond

for2.end:
  ; 打印结果
  %final_sum = load i32, ptr %sum, align 4
  call void (ptr, ...) @putf(ptr @.str3, i32 %final_sum)
  
  ret i32 0
}