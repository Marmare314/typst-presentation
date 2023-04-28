#import "slides.typ": presentation, hide-slide, dynamic-slide

#show: presentation.with(
  title: "Presentation title",
  author: "John Doe",
  title-text: "Some additional text",
)

= Topic A
== Section A
#lorem(20)
== Section B
#lorem(30)

= Very Long Slide
#lorem(200)

=
Slide without a banner.

= $L^p$
Slide with math banner.

#show: dynamic-slide
= Topic B
== Section A
#lorem(20)
== Section B #hide-slide(1)
#lorem(20)
== Section C
#lorem(20)

= Topic C
Just a boring slide

#show: dynamic-slide
= Topic D
== Section 1
Content 1
== Section 2 #hide-slide(1)
Content 2
== Section 3 #hide-slide((1, 2))
Content 3
== Section 4
Content 4
