#let _get-current-slide(content) = {
  let start-next = content.children.slice(1).position(c => c.func() == heading and c.level == 1)
  if start-next != none {
    (content.children.slice(0, start-next), content.children.slice(start-next).sum())
  } else {
    (content.children, [])
  }
}

#let _split-by-headings(content) = {
  let result = ()
  while content.len() > 0 {
    let current-heading = content.first()
    assert(current-heading.func() == heading)
    content = content.slice(1)

    let next-heading = content.position(c => c.func() == heading and (c.level == 1 or c.level == 2))

    if next-heading == none {
      next-heading = content.len()
    }
    let current-body = content.slice(0, next-heading)
    content = content.slice(next-heading)

    result.push((current-heading, current-body))
  }
  result
}

#let _split-current-slide(content) = {
  let sections = _split-by-headings(content)
  (sections.first().first(), sections.slice(1))
}

#let _remove-internal(h) = {
  if h.has("label") {
    panic("labels are not supported")
  } else {
    heading(
        level: h.level,
        h.body.children.filter(c => not (c.func() == text and c.text.starts-with("slide-internal:"))).sum(),
    )
  }
}

#let _get-slide-info(sections) = {
  let result = ()
  for (h, body) in sections {
    if h.body.has("children") {
      let infos = h.body.children.filter(c  => c.func() == text and c.text.starts-with("slide-internal:"))
      assert(infos.len() == 1)

      result.push((_remove-internal(h), body, eval(infos.first().text.trim("slide-internal:"))))
    } else {
      result.push((h, body, ()))
    }
  }
  result
}

#let _array-to-set(arr) = {
  let result = ()
  let last = none
  for i in arr.sorted() {
    if i != last {
      result.push(i)
      last = i
    }
  }
  result
}

#let dynamic-slide(content) = {
  let (current, remaining-content) = _get-current-slide(content)
  let (heading, sections) = _split-current-slide(current)
  let sections_with_info = _get-slide-info(sections)
  let indices = _array-to-set(sections_with_info.map(((a, b, c)) => c).flatten())

  for i in indices + (indices.last() + 1,) {
    heading
    for (header, body, info) in sections_with_info {
      if info.contains(i) {
        hide(
          header + body.sum()
        )
      } else {
        header
        body.sum()
      }
    }
  }

  remaining-content
}

#let hide-slide(slides) = {
  slides = (slides,).flatten()
  text("slide-internal:" + repr(slides))
}

#let presentation(
  title: none,
  author: none,
  title-text: none,
  fg-color: blue,
  bg-color: white,
  size: "presentation-4-3",
  content
) = {
  set page(paper: size)
  set text(size: 23pt)

  align(horizon)[
    #if title != none {
      align(center, text(fg-color, title))
    }

    #if author != none {
      align(center, author)
    }

    #if title-text != none {
      align(center, title-text)
    }
  ]

  show page: it => {
    align(horizon, it)
  }
  set page(header: {
    locate(loc => {
      let headings = query(heading.where(level: 1).after(loc), loc)
      if headings.len() > 0 {
        let slide-title = headings.first().body
        if not (slide-title.has("children") and slide-title.children.len() == 0) {
          rect(
            fill: fg-color,
            width: 100%,
            height: 100%,
            align(horizon, text(bg-color, slide-title))
          )
        }
      }
    })
  })
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    place(hide(it))
  }
  show heading.where(level: 2): it => block(text(fg-color, it.body))

  content
}
