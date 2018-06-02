## v0.2.0 (2018-06-02)
* Return of Changeset validation that was in formex < 0.5. Read more in UPGRADE.md
* Renamed callback `changeset_after_create_callback` to `modify_changeset`
* Removed `changeset_validation` callback - rules should be moved to `modify_changeset`

## v0.1.10 (2018-06-02)
* The Changeset Validator was using `changeset_after_create_callback` although this callback was
  made to change normal changeset, not the fake one that creates this validator. Now this callback
  is not firing while performing validation.

## v0.1.9 (2018-04-01)
* Fixed using `multiple_select` with array field

## v0.1.8 (2018-01-23)
* Fixed package requirements

## v0.1.7 (2018-01-22)
* Added ability to control which fields will be casted via `Ecto.Changeset.cast/3`.
  It was required by packages like `Arc.Ecto`.

## v0.1.6 (2017-12-10)
* Added `search` function in `SelectAssoc`, to be used with Ajax select plugins.

## v0.1.5 (2017-12-05)
* Added support for option `without_choices` in `SelectAssoc` - Formex 0.5.9
* Fixed `phoenix_opts` in `multiple_select` in `SelectAssoc`

## v0.1.4 (2017-11-19)
* Form collections ordered by id

## v0.1.3 (2017-09-08)
* Added ability to use a different field name than in a structure - Formex 0.5.5

## v0.1.2 (2017-08-31)
* Fixed passing options in `SelectAssoc`. For example, the `label` option wasn't work
