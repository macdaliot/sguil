# $Id: SguildCreateDB.tcl,v 1.1 2004/10/05 15:23:20 bamm Exp $

proc CreateDB { DBNAME } {
  global dbSocketID
  puts -nonewline "The database $DBNAME does not exist. Create it (\[y\]/n)?: "
  flush stdout
  set answer [gets stdin]
  if { $answer == "" } { set answer y }
  if { ![regexp {^[yY]} $answer] } { return 0 }
  set fileName "./sql_scripts/create_sguildb.sql"
  puts -nonewline "Path to create_sguildb.sql \[$fileName\]: "
  flush stdout
  set answer [gets stdin]
  if { $answer != "" } { set fileName $answer }
  if { ! [file exists $fileName] } {
    puts "File does not exist: $fileName"
    return 0
  }
  puts -nonewline "Creating the DB $DBNAME..."
  if [ catch {mysqlexec $dbSocketID "CREATE DATABASE $DBNAME"} createDBError] {
    puts $createDBError
    return 0
  }
  mysqluse $dbSocketID $DBNAME
  puts "Okay."
  if [catch {set fileID [open $fileName r]} openFileError] {
    puts $openFileError
    return 0
  }
  puts -nonewline "Creating the structure for $DBNAME: "
  foreach line [split [read $fileID] \n] {
    puts -nonewline "."
    if { $line != "" && ![regexp {^--} $line]} {
      #puts "LINE: $line"
      if { [regexp {(^.*);\s*$} $line match data] } {
        lappend mysqlCmd $data
        #puts "CMD: [join $mysqlCmd]"
        mysqlexec $dbSocketID [join $mysqlCmd]
        set mysqlCmd ""
      } else {
        lappend mysqlCmd $line
      }
    }
  }
  close $fileID
  puts "Done."
  return 1
}

