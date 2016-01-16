module.exports = (md, raw, extension = "") ->
    md.render("``` #{extension}\n" + raw + "\n```")
