#let template(resume) = [
  #set line(length: 100%, stroke: 0.5pt + black)
  #set list(indent: 0.5em)
  #set page("us-letter", margin: 0.5in)
  #set par(linebreaks: "simple", leading: 0.8em, spacing: 1.5em)
  #set text(font: "Nimbus Sans L", size: 10pt)

  #show heading.where(level: 1): set text(size: 18pt)
  #show heading.where(level: 2): set block(above: 1.5em)

  #let parse(date) = {
    datetime(year: date.year, month: date.month, day: date.day)
  }

  #let headline(name, desc, detail: none, timing) = {
    box[#pad(right: 0.4em)[*#name*]]
    [#desc]
    if detail != none [
      — #detail
    ]
    h(1fr)
    [#timing]
  }

  #let monthrange(startdate, enddate: none) = {
    let format = "[month repr:short] [year repr:full]"

    parse(startdate).display(format)
    if enddate == none [
      \- Present
    ] else [
      \- #parse(enddate).display(format)
    ]
  }

  #let education(education) = {
    block[
      #headline(
        (education.studyType, education.area)
          .filter(item => item.len() > 0)
          .join(", "),
        none,
        parse(education.endDate).display("[month repr:short] [year repr:full]"),
      )
      #box[
        #education.institution \
        #if education.courses.len() > 0 {
          [Honors: #education.courses.join(", ") ]
        } \
        GPA: #education.score \
      ]
    ]
  }

  #let clincalrotation(cr) = {
    block[
      #headline(
        cr.position.split(", ").at(1),
        cr.name,
        detail: cr.at("location", default: none),
        cr.description,
      ) \
      #list(..cr.highlights)
    ]
  }

  #let work(w) = {
    block[
      #headline(
        w.position,
        none,
        monthrange(w.startDate, enddate: w.endDate),
      ) \
      #w.name — #w.at("location", default: none)
      #list(..w.highlights)
    ]
  }

  #let project(p) = {
    let (entity, city, state) = p.entity.split(", ")

    if p.type == "presentation" {
      let (authors, title) = p.name.split(". ")

      block[
        #headline(
          "Presenter",
          none,
          parse(p.startDate).display("[month repr:short] [year repr:full]"),
        ) \
        #entity — #city, #state
        #list(
          [#authors. #emph(title).],
          ..p.highlights,
        )
      ]
    } else {
      block[
        #headline(
          p.name,
          none,
          monthrange(p.startDate, enddate: p.endDate),
        ) \
        #entity — #city, #state
        #list(..p.highlights)
      ]
    }
  }

  #let singleton(item, detail) = {
    list.item([

      #box[#pad(right: 0.4em)[#item]]
      #h(1fr)
      #detail
    ])
  }

  #let nicelink(l) = {
    let authority = l.split(regex("(://)|:")).last()
    link(l)[#authority]
  }

  #let twocolumn(leftcontent, rightcontent) = {
    grid(
      columns: 3,
      leftcontent, h(1fr), rightcontent,
    )
  }

  // DOCUMENT START

  #align(center)[
    = #resume.basics.name
    #resume.basics.email | #resume.basics.phone
  ]

  == Education

  #line()

  #(
    resume.education.map(e => education(e)).join()
  )

  == Clinical Rotations

  #line()

  #(
    resume
      .work
      .filter(w => w.position.starts-with("Clinical Rotation"))
      .map(w => clincalrotation(w))
      .join()
  )

  == Work Experience

  #line()

  #(
    resume
      .work
      .filter(w => not w.position.starts-with("Clinical Rotation"))
      .map(w => work(w))
      .join()
  )

  == Scholarly Activities

  #line()

  #(
    resume
      .projects
      .filter(p => p.type == "project" or p.type == "presentation")
      .map(p => project(p))
      .join()
  )

  == Licenses & Certifications

  #line()


  #(
    resume
      .projects
      .filter(p => p.type == "certification")
      .map(p => singleton(p.name, monthrange(p.startDate, enddate: p.endDate)))
      .join()
  )


  == Professional Memberships

  #line()

  #(
    resume
      .projects
      .filter(p => p.type == "membership")
      .map(p => singleton(p.name, monthrange(p.startDate, enddate: p.endDate)))
      .join()
  )

  == Community Involvement

  #line()

  #resume.volunteer.map(v => singleton(v.organization, v.startDate)).join()

  // DOCUMENT END
]

#template(json(sys.inputs.data_path))
