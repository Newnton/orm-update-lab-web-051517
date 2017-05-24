require_relative "../config/environment.rb"

class Student
  require 'pry'
  attr_accessor :name, :grade, :id
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE students;')
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET (name, grade) = (?, ?)
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if @id
      self.update
    else
      DB[:conn].execute('INSERT INTO students (name, grade) VALUES (?, ?)', @name, @grade)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).flatten
    new_from_db(row)
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1], row[2], row[0])
    new_student
  end
end
