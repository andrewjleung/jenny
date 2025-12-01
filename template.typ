#let template(resume) = [
  #set line(length: 100%, stroke: 0.5pt + black)
  #set list(indent: 0.5em)
  #set page("us-letter", margin: 0.5in)
  #set par(linebreaks: "simple", leading: 1em, spacing: 1.1em)
  #set text(font: "Nimbus Sans L", size: 10pt)

  #show heading.where(level: 1): set text(size: 18pt)

  #let parse(date) = {
    datetime(year: date.year, month: date.month, day: date.day)
  }

  #let education(education) = {
    box[#pad(right: 0.4em)[*#education.studyType, #education.area*]]
    h(1fr)
    parse(education.endDate).display("[month repr:short] [year repr:full]")

    block[#education.institution]

    if education.courses.len() > 0 {
      block[Honors: #education.courses.join(", ")]
    }

    block[GPA: #education.score]
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
      .map(w => [#headline(
          w.name,
          w.position.split(", ").at(1),
          detail: w.at("location", default: none),
          w.description,
        )

        #list(..w.highlights)
      ])
      .join()
  )

  == Work Experience

  #line()

  #(
    resume
      .work
      .filter(w => not w.position.starts-with("Clinical Rotation"))
      .map(w => [#headline(
          w.name,
          w.position,
          detail: w.at("location", default: none),
          monthrange(w.startDate, enddate: w.endDate),
        )

        #list(..w.highlights)
      ])
      .join()
  )

  == Scholarly Activities
  #line()

  == Licenses & Certifications
  #line()

  == Professional Memberships
  #line()

  == Community Involvement
  #line()

  // DOCUMENT END
]

#template(json(sys.inputs.data_path))
