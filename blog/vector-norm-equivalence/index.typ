#import "/content/_typst_ts_tmpl/template.typ": *

#show: project.with(title: "Some Thoughts on Vector Norm Equivalence", date: datetime(
  year: 2024,
  month: 12,
  day: 14,
  hour: 23,
  minute: 00,
  second: 00,
), description: "A revisit to linalg for 4 years")

== Intro

矩阵理论与方法课程的向量范数部分提到了一个重要的定理，参见@orig-proof[图] ，它指出 $bb(V)^n$ 上所有向量范数都等价. 虽然向量范数等价并不是一个特别强的关系，但它确实足够非平凡. 而且原始证明的思路也很有趣，它从何而来？

1. 范数的齐次性，实际上我们的结论可以写成 $c_1 <= (norm(x)_alpha)/(norm(x)_2) <= c_2$；中间这项是两个齐次函数相除，我们有 $f(k x)=f(x)$；这样一来，规定 $norm(x)=1$ 并利用一个函数 $min,max$ 的思路本就呼之欲出了.
2. 范数的连续性.
3. 约束 $norm(x)_2=1$ 一定是一个闭区域.

后两者都是幻灯片证明中未加展开的细节. 下文将详细阐述它们，并给出不指定 $norm(dot.c)_2$ 而是直接强行取任意两个范数 $norm(dot.c)_alpha,norm(dot.c)_beta$ 证明其等价的证明方法.

== The Skip in the Original Proof

图中证明取出子集 $S$ 后，立刻得到了它是一个*闭区域*. 这是没问题的，因为我们已经选定了 $norm(dot.c)_2$，因此其闭性质只是一个经典几何问题. 但是证明紧接着指出了任意向量范数对应的函数 $f:bb(V)^n -> bb(R)$ 是连续函数，这一点必须要加以证明才行.

这里有一个容易混淆的地方：连续性基于极限，而极限依赖一个度量. 范数当然是一个度量，于是我们可能会惯性地使用 $norm(dot.c)_alpha$ 来定义连续性. 但那样就不是我们一般已经证明过的具有良好性质的函数连续性了. 考虑到我们后续需要使用引理「*闭区域上的连续函数有界*」，我们最好以 $norm(dot.c)_2$ 为度量证明连续性，则引理不需要另外加以证明了.

证：

$norm(dot.c)_alpha$ 连续意味着我们需要证明 $display(forall x_0 in bb(V)^n:lim_(x -> x_0)norm(x)_alpha=norm(x_0)_alpha)$.

取一组基 ${b_i}$ 用于表示两个向量的坐标：$x={u_i}, x_0={v_i}$.

$
abs(norm(x)_alpha - norm(x_0)_alpha)
& <= norm(x-x_0)_alpha \
& = norm(sum_i (u_i-v_i) b_i)_alpha \
& <= sum_i abs(u_i-v_i) norm(b_i)_alpha&(#[Triangular])\
& <=sqrt(sum_i abs(u_i-v_i)^2) sqrt(sum_i norm(b_i)_alpha^2) & (#[Caulhy-Schwarz])\
& =J norm(x-x_0)_2& (#[where ] inline(J = sqrt(sum_i norm(b_i)_alpha^2)))
$

那么，对于任意给定的 $epsilon >0$，当我们有 $norm(x-x_0)_2 < epsilon$ 时，只需取 $ delta = J epsilon$ 即可依据上述不等式使得极限得证. $qed$

---

这里实际上可以窥见各个向量范数间的真正联系. $norm(dot.c)_2$ 没有什么特殊的，但是我们使用三角不等式将其坐标表示化成了一个带系数的 $norm(dot.c)_1$ 的形式，紧接着使用柯西不等式将其转换到 $norm(dot.c)_2$. 也就是说，真正特殊的、被写在向量范数的定义里、作为所有范数的基准的范数其实是三角不等式所定义的 $norm(dot.c)_1$. 这里系数 $J$ 更是描述了基向量组在某个范数下的度量系数，例如如果是 $norm(dot.c)_1$，我们会使用 $ sum_i norm(b_i)_alpha$ ，很有意思.

当然，任意度量空间都尊重三角不等式，这里是因为向量空间的坐标表示又额外提供了特殊性.

== A General Proof

接下来我们直接证明 $norm(dot.c)_alpha$ 和 $norm(dot.c)_beta$ 等价.

证：

考虑定义式

$
exists c_1,c_2 in bb(R)^+;forall x in bb(V)^n:c_1norm(x)_beta<=norm(x)_alpha<= c_2norm(x)_beta
$

$x=bold(0)$ 的情形显然成立，下面考虑 $x eq.not bold(0)$，那么所有范数都是正实数，可对目标作化简：

$
c_1 <= (norm(x)_alpha) / (norm(x)_beta) <= c_2
$

记 $f(x) := (norm(x)_alpha)/(norm(x)_beta)$，我们只需要证明

$
A:={f(x) mid(|) x in bb(V)^n},c_1<= min A and max A<= c_2
$

注意到范数的齐次性，那么对于 $forall k in bb(R),f(k x)=f(x)$. 我们进一步可以发现

$
A={f(x) mid(|) x in bb(V)^n}={f(x) mid(|) x in bb(V)^n and norm(x)_beta=1}=:B
$

这是因为不满足约束的向量都可以归一化，并通过等式归约到满足约束的情形. 接下来我们只需要考察 $min B, max B$ .

---

首先上文已经证明 $f(x)$ 是连续函数，下面我们证明 $X:={x in bb(V)^n mid(|) norm(x)_beta=1}$ 是 $bb(V)^n$ 上 $norm(dot.c)_2$ 度量意义下的闭区域.

任取一点 $x in X$，考虑 $x$ 的任意去心邻域 $dot(U)(x, delta)$. 我们首先可以找到一个点集 $Y={(1+ epsilon) x mid(|) epsilon>0}$，它满足：

1. $Y$ 中所有点在目标集 $X$ 之外 \
	考虑 $forall y in Y$，$norm(y)_beta=norm((1+ epsilon)x)_beta=(1+ epsilon)norm(x)_beta>norm(x)_beta=1$ ，得证.
2. $Y$ 和所选定去心邻域 $dot(U)(x, delta)$ 有非空交集 \
	考虑两个集合的交，也即$X_0:=Y sect dot(U)(x, delta)={y mid(|) y in Y and norm(x-y)_2= epsilon norm(x)_2< delta}={ (1+epsilon) x mid(|) 0< epsilon< delta/norm(x)_2}$ 显然非空.

交集 $X_0$ 非空意味着我们找到了任意去心邻域中在 $X$ 之外的点，因此 $x$ 是边界点. 所以 $X$ 中所有点都属于其边界. 那么显然 $X$ 是闭区域.

综上所述，$f(x)$ 在闭区域 $X$ 上连续，因此它有最大值和最小值 $min B,max B$. 因此可以取 $c_1=min B,c_2=max B$，原命题得证. $qed$

---

距离大一的线性代数与几何课程已经四年了. 时隔四年再次学习矩阵论的内容，前半部分大段的概念让我感到了实实在在的压力.
（咳咳，当然也怪我偶尔会翘课）

这种程度的遗忘应该比较正常，毕竟这几年都投入别的事情去了……
某些代数直觉已经忘光了，需要重建. 好好看过一遍之后似乎就好了很多，后半部分的计算与证明总算上手了一些.
我想起来高中时学习数学的一大乐趣是用 LaTeX 排出漂亮的证明. 本身书写与重复就是练习的一部分，希望以后也能继续排版.

当然，现在是用 Typst.

== Appendix

#figure(image("orig-proof-1.svg"), caption: "原始证明的第一部分") <orig-proof>

#figure(image("orig-proof-2.svg"), caption: "原始证明的第二部分")
