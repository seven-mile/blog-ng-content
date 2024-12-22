#import "/content/_typst_ts_tmpl/template.typ": *
#import "@preview/ctheorems:1.1.3": *

#show: project.with(title: "Modal Logic Operator Reduction", date: datetime(
  year: 2024,
  month: 12,
  day: 22,
  hour: 19,
  minute: 05,
  second: 00,
), description: "A small problem during exam review")

#show: thmrules.with(qed-symbol: $square$)

#let theorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let lemma = thmbox("lemma", "Lemma", fill: rgb("#eeeeff"))
#let definition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em))
#let proof = thmproof("proof", "Proof")

高级数理逻辑 19-20 年的试卷有道题，网上的标准答案也自称不会做。这里记录一下做法。

背景是模态逻辑形式系统 KD45。下面是证明中公理的记号表，避免混淆：

#table(
  columns: 2,
  inset: 8pt,
  [*记号*],[*公理*],
  $A_D$, $square A -> diamond A$,
  $A_4$, $square A -> square square A$,
  $A_5$, $diamond A -> square diamond A$,
)

题目要求证明以下定理：

#theorem("Main", numbering: none)[模态逻辑形式系统 KD45 的模态词规约于 $square, diamond, not square, not diamond$.]

先来看一个引理。

#lemma($L_1$, numbering: none)[KD45 上有 $diamond diamond A -> diamond A$.]

#proof[
对 $A_4$ 取逆否，得到 $not square square A -> not square A$，也即 $diamond diamond not A -> diamond not A$. 由于这是定理，替换 $A$ 后得证。
]

这算是逻辑对偶定理运用的典例了。对于永真式这么做是很好用的。接下来证明原题目。

#proof[
首先从简单的入手，先证 $diamond diamond = diamond$，再考虑另外三种组合。

$
  (1) space & diamond A -> square diamond A & (A_5) \
  (2) space & square diamond A -> diamond diamond A & (A_D) \
  (3) space & diamond A -> diamond diamond A & (1, 2) \
  (4) space & square diamond A -> diamond A & (2, L_1)
$

结合 $(L_1,3)$, 我们有 $diamond diamond = diamond$.

结合 $(1,4)$，我们有 $square diamond = diamond$.

根据对偶原理我们直接得到 $square square = square, diamond square = square$. 或者也可以不弄那么玄学的，根据 $not diamond = square not$，稍加替换，再抵消否定也可以证明。

综上所述，二重模态词的四种组合都可规约为单模态词。根据数学归纳法，任意模态词组合都可规约为定理中的单模态词或其否定。
]

一开始做繁了，为了证明 $diamond square = square$，又用 $A_5$ 的对偶写了一段，突然想到似乎可以直接在算子等式上用否定公理。这样整体的证明还不是很乱。形式系统的证明是很容易乱的。

不过这道题在语义下似乎反而更不直观，这套公理组对应的图性质怪怪的。感兴趣的读者可以做做精神体操。
