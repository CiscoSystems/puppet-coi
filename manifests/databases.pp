define coi::databases(
  $db_type = 'mysql',
) {

  include "::${name}::db::${db_type}"

}
