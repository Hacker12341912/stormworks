matrix = [[6, 7, 8, 9, 10], [4, 1, 2, 3, 5], [11, 12, 13, 14, 15]]

for i in matrix:
    for j in i:
        print (j)

num = 0
for i in matrix:
    for j in i:
        num += 1
print (str(num) + " elements in the matrix")
