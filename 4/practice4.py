class Book:
    def __init__(self, title, author):
        self.title = title
        self.author = author
    def describe(self):
        return f"{self.title} by {self.author}"

book1 = Book("To Kill a Mockingbird", "Harper Lee")
book2 = Book("1984", "George Orwell")

print(book1.describe())
print(book2.describe())

print(book1.title, book1.author)
print(book2.title, book2.author)

class Student:
    def __init__ (self, name):
        self.name = name

student1 = Student("Bennett")
student2 = Student("Wendy")
student3 = Student("Roger")

print(student1.name)
print(student2.name)
print(student3.name)