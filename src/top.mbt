///|
type Any

///|
trait Functor {
  map(Any, (Any) -> Any) -> Any
}

///|
fn _coerce[A, B](x : A) -> B = "%identity"

///|
fn coerce[A, B](x : A) -> B {
  _coerce((_coerce(x) : Any)) // disable incompatible pointer type warning in native backend
}

///|
typealias VMap = (Any, (Any) -> Any) -> Any

///|
impl[A] Functor for Array[A] with map(xs, f) {
  let m : (Array[Any], (Any) -> Any) -> Array[Any] = Array::map
  let m : VMap = coerce(m)
  m(xs, f)
}

///|
impl[A] Functor for A? with map(xs, f) {
  let m : (Ref[Any]?, (Ref[Any]) -> Ref[Any]) -> Ref[Any]? = Option::map
  let m : VMap = coerce(m)
  m(xs, f)
}

///|
fn map[F : Functor, A, B, R : Functor](xs : F, f : (A) -> B) -> R {
  coerce(F::map(coerce(xs), coerce(f)))
}

///|
trait Monad: Functor {
  bind(Any, (Any) -> Any) -> Any
}

///|
typealias VBind = (Any, (Any) -> Any) -> Any

///|
impl[A] Monad for Array[A] with bind(xs, f) {
  let m : (Array[Any], (Any) -> Array[Any]) -> Array[Any] = fn(xs, f) {
    let res = []
    for x in xs {
      res.append(f(x))
    }
    res
  }
  let m : VBind = coerce(m)
  m(xs, f)
}

///|
impl[A] Monad for A? with bind(xs, f) {
  let m : (Ref[Any]?, (Ref[Any]) -> Ref[Any]?) -> Ref[Any]? = Option::bind
  let m : VBind = coerce(m)
  m(xs, f)
}

///|
fn bind[M : Monad, A, R : Monad](xs : M, f : (A) -> R) -> R {
  coerce(M::bind(coerce(xs), coerce(f)))
}

///|
test "bind" {
  let xs = Array::makei(10, fn { i => Ref::new(i) })
  let ys : Array[Ref[Double]] = bind(xs, fn(
    x : Ref[Int]
  ) -> Array[Ref[Double]] {
    [Ref::new(x.val.to_double() + 0.01)]
  })
  inspect!(
    ys,
    content="[{val: 0.01}, {val: 1.01}, {val: 2.01}, {val: 3.01}, {val: 4.01}, {val: 5.01}, {val: 6.01}, {val: 7.01}, {val: 8.01}, {val: 9.01}]",
  )
}

///|
test "map" {
  let x = Array::makei(10, fn { i => Ref::new(i) })
  let val : Array[Ref[Int]] = map(x, fn(x : Ref[Int]) { Ref::new(x.val + 10) })
  inspect!(
    val,
    content="[{val: 10}, {val: 11}, {val: 12}, {val: 13}, {val: 14}, {val: 15}, {val: 16}, {val: 17}, {val: 18}, {val: 19}]",
  )
  let x = Some(Ref::new(99))
  let val : Ref[Int]? = map(x, fn(x : Ref[Int]) { Ref::new(x.val + 10) })
  inspect!(val, content="Some({val: 109})")
}
