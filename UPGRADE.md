# Upgrade from 0.1 to 0.2

  ## TLDR;

  * Rename `changeset_after_create_callback` to `modify_changeset`
  * Move your validation rules from `changeset_validation` to `modify_changeset`

  ## Full story

  After extracting ecto related code from main `formex` library to `formex_ecto`
  errors from changeset wasn't used anymore.
  This library introduced `Formex.Changeset.Validator` that let us use validation functions
  included in `Ecto.Changeset` module. This module creates a fake changeset to perform validation.

  In previous version `formex_ecto` was raising error if there was an error in changeset after
  insert/update failure. This error was introduced because we should use new callback
  `changeset_validation` instead of `changeset_after_create_callback`.

  There is one issue with this approach - `Ecto` can also add an error to changeset on it's own.
  For example - if there is an `UNIQUE` constraint then `Ecto` will attach error to the changeset
  after failure of database query. So `formex_ecto` was raising error even though programmer
  didn't make a mistake with callbacks.

  From now instead of raising error, all errors from changeset are passed back to the form and
  displayed for user. Just like in the `formex` before 0.5 version.

  Another change is renaming a long `changeset_after_create_callback` to a shorter
  `modify_changeset`. This update was a good occasion to do that. When I first introduced this
  callback I thought there will be need for to make much more similar callbacks
  (like in Symfony & Doctrine) but no one asked for them yet.

  The `changeset_validation` callback is removed. You should move validation rules to the
  `modify_changeset`. If you are using validation attached to field
  (`add(:name, :text_input, validation: [  __some changeset's rules__  ])`)
  you don't need to change it. They are still performed on a fake changeset mentioned before.


