class Car:

    def __init__(self, make, model, color):

        self.make = make

        self.model = model

        self.color = color

car1 = Car("Honda", "Odyssey", "blue")
car2 = Car("Toyota", "Camry", "red")

print(car1.make, car1.model, car1.color)
print(car2.make, car2.model, car2.color)