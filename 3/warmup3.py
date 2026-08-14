#Ask the user for a number and then use for loops to print out the squares of all the numbers from 1 to the inputted number. For example: if I input 5 then the output should be 1, 4, 9, 16, 25 (one number on each line). Bonus: Make the code output only the squares of even numbers.
#Ask the user for a string, as well as a character. Count the total number of occurrences that this character shows up in the string. Example: str is “hello world”, the char is  ‘o’; then the output should be 2. Try to use a function for this one if you can.
#Use lists to create a wishlist. Ask the user repeatedly for anything that they would like to add to the wishlist, until they type ‘q’ to stop adding more items. You should be adding all of the items onto a list. Then you should output all the items at the end.
#Ask the user for numbers repeatedly, until they input 0. Then with this list, find the average of the set and output it. Example: if my inputs are 3,6,7,4; then my output is 

number = int(input("Enter a number: "))
for i in range(1, number + 1):
    if i == 0:
        print(i ** 2)

def count_occurrences(string, char):
    count = 0
    for c in string:
        if c == char:
            count += 1
    return count

user_string = input("Enter a string: ")
user_char = input("Enter a character to count: ")
occurrences = count_occurrences(user_string, user_char)
print(f"The character '{user_char}' occurs {occurrences} times in the string.")     


wishlist = []
while True:
    item = input("Enter an item to add to your wishlist (or 'q' to quit): ")
    if item.lower() == 'q':
        break
    wishlist.append(item)
print("Your wishlist:")
for item in wishlist:
    print(item)
numbers = []
while True:

    num = int(input("Enter a number (or 0 to stop): "))
    if num == 0:
        break
    numbers.append(num)
if numbers:
    average = sum(numbers) / len(numbers)
    print(f"The average of the numbers is: {average}")
else:
    print("No numbers were entered.")







            