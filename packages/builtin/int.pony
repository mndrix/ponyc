primitive I8 is SignedInteger[I8]
  new create(from: I8) => compiler_intrinsic

  fun abs(): I8 => if this < 0 then -this else this end
  fun max(that: I8): I8 => if this > that then this else that end
  fun min(that: I8): I8 => if this < that then this else that end

  fun bswap(): I8 => this
  fun popcount(): I8 => @"llvm.ctpop.i8"[I8](this)
  fun clz(): I8 => @"llvm.ctlz.i8"[I8](this, false)
  fun ctz(): I8 => @"llvm.cttz.i8"[I8](this, false)
  fun bitwidth(): I8 => 8

  fun addc(y: I8): (I8, Bool) =>
    @"llvm.sadd.with.overflow.i8"[(I8, Bool)](this, y)
  fun subc(y: I8): (I8, Bool) =>
    @"llvm.ssub.with.overflow.i8"[(I8, Bool)](this, y)
  fun mulc(y: I8): (I8, Bool) =>
    @"llvm.smul.with.overflow.i8"[(I8, Bool)](this, y)

primitive I16 is SignedInteger[I16]
  new create(from: I16) => compiler_intrinsic

  fun abs(): I16 => if this < 0 then -this else this end
  fun max(that: I16): I16 => if this > that then this else that end
  fun min(that: I16): I16 => if this < that then this else that end

  fun bswap(): I16 => @"llvm.bswap.i16"[I16](this)
  fun popcount(): I16 => @"llvm.ctpop.i16"[I16](this)
  fun clz(): I16 => @"llvm.ctlz.i16"[I16](this, false)
  fun ctz(): I16 => @"llvm.cttz.i16"[I16](this, false)
  fun bitwidth(): I16 => 16

  fun addc(y: I16): (I16, Bool) =>
    @"llvm.sadd.with.overflow.i16"[(I16, Bool)](this, y)
  fun subc(y: I16): (I16, Bool) =>
    @"llvm.ssub.with.overflow.i16"[(I16, Bool)](this, y)
  fun mulc(y: I16): (I16, Bool) =>
    @"llvm.smul.with.overflow.i16"[(I16, Bool)](this, y)

primitive I32 is SignedInteger[I32]
  new create(from: I32) => compiler_intrinsic

  fun abs(): I32 => if this < 0 then -this else this end
  fun max(that: I32): I32 => if this > that then this else that end
  fun min(that: I32): I32 => if this < that then this else that end

  fun bswap(): I32 => @"llvm.bswap.i32"[I32](this)
  fun popcount(): I32 => @"llvm.ctpop.i32"[I32](this)
  fun clz(): I32 => @"llvm.ctlz.i32"[I32](this, false)
  fun ctz(): I32 => @"llvm.cttz.i32"[I32](this, false)
  fun bitwidth(): I32 => 32

  fun addc(y: I32): (I32, Bool) =>
    @"llvm.sadd.with.overflow.i32"[(I32, Bool)](this, y)
  fun subc(y: I32): (I32, Bool) =>
    @"llvm.ssub.with.overflow.i32"[(I32, Bool)](this, y)
  fun mulc(y: I32): (I32, Bool) =>
    @"llvm.smul.with.overflow.i32"[(I32, Bool)](this, y)

primitive I64 is SignedInteger[I64]
  new create(from: I64) => compiler_intrinsic

  fun abs(): I64 => if this < 0 then -this else this end
  fun max(that: I64): I64 => if this > that then this else that end
  fun min(that: I64): I64 => if this < that then this else that end

  fun bswap(): I64 => @"llvm.bswap.i64"[I64](this)
  fun popcount(): I64 => @"llvm.ctpop.i64"[I64](this)
  fun clz(): I64 => @"llvm.ctlz.i64"[I64](this, false)
  fun ctz(): I64 => @"llvm.cttz.i64"[I64](this, false)
  fun bitwidth(): I64 => 64

  fun addc(y: I64): (I64, Bool) =>
    @"llvm.sadd.with.overflow.i64"[(I64, Bool)](this, y)
  fun subc(y: I64): (I64, Bool) =>
    @"llvm.ssub.with.overflow.i64"[(I64, Bool)](this, y)
  fun mulc(y: I64): (I64, Bool) =>
    @"llvm.smul.with.overflow.i64"[(I64, Bool)](this, y)

primitive I128 is SignedInteger[I128]
  new create(from: I128) => compiler_intrinsic

  fun abs(): I128 => if this < 0 then -this else this end
  fun max(that: I128): I128 => if this > that then this else that end
  fun min(that: I128): I128 => if this < that then this else that end

  fun bswap(): I128 => @"llvm.bswap.i128"[I128](this)
  fun popcount(): I128 => @"llvm.ctpop.i128"[I128](this)
  fun clz(): I128 => @"llvm.ctlz.i128"[I128](this, false)
  fun ctz(): I128 => @"llvm.cttz.i128"[I128](this, false)
  fun bitwidth(): I128 => 128

  fun string(fmt: IntFormat = FormatDefault,
    prefix: NumberPrefix = PrefixDefault, prec: U64 = 1, width: U64 = 0,
    align: Align = AlignRight, fill: U32 = ' '): String iso^
  =>
    ToString._u128(abs().u128(), this < 0, fmt, prefix, prec, width, align,
      fill)

  fun divmod(y: I128): (I128, I128) =>
    if Platform.has_i128() then
      (this / y, this % y)
    else
      if y == 0 then
        return (0, 0)
      end

      var num: I128 = this
      var den: I128 = y

      var minus = if num < 0 then
        num = -num
        true
      else
        false
      end

      if den < 0 then
        den = -den
        minus = not minus
      end

      let (q, r) = num.u128().divmod(den.u128())
      var (q', r') = (q.i128(), r.i128())

      if minus then
        q' = -q'
      end

      (q', r')
    end

  fun div(y: I128): I128 =>
    if Platform.has_i128() then
      this / y
    else
      let (q, r) = divmod(y)
      q
    end

  fun mod(y: I128): I128 =>
    if Platform.has_i128() then
      this % y
    else
      let (q, r) = divmod(y)
      r
    end

  fun f32(): F32 => this.f64().f32()

  fun f64(): F64 =>
    if this < 0 then
      -(-this).f64()
    else
      this.u128().f64()
    end
