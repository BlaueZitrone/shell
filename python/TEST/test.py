def smallerPathSum(x_now, y_now, sum_now, grid, x_max, y_max):
    #print("x_now:", x_now, ",y_now:", y_now, ",sum_now:", sum_now, ",grid:", grid, ",x_max:", x_max, ",y_max:" ,y_max)
    if x_now == x_max:
        if y_now == y_max: return sum_now
        else: return smallerPathSum(x_now, y_now+1, sum_now+grid[x_now][y_now+1], grid, x_max, y_max)
    else:
        if y_now == y_max: return smallerPathSum(x_now+1, y_now, sum_now+grid[x_now+1][y_now], grid, x_max, y_max)
        else: return min(smallerPathSum(x_now, y_now+1, sum_now+grid[x_now][y_now+1], grid, x_max, y_max), smallerPathSum(x_now+1, y_now, sum_now+grid[x_now+1][y_now], grid, x_max, y_max))

def minPathSum(grid):
    x_max = len(grid) - 1
    y_max = len(grid[0]) - 1
    return smallerPathSum(0, 0, grid[0][0], grid, x_max, y_max)

grid_01 = [[7,1,3,5,8,9,9,2,1,9,0,8,3,1,6,6,9,5],[9,5,9,4,0,4,8,8,9,5,7,3,6,6,6,9,1,6],[8,2,9,1,3,1,9,7,2,5,3,1,2,4,8,2,8,8],[6,7,9,8,4,8,3,0,4,0,9,6,6,0,0,5,1,4],[7,1,3,1,8,8,3,1,2,1,5,0,2,1,9,1,1,4],[9,5,4,3,5,6,1,3,6,4,9,7,0,8,0,3,9,9],[1,4,2,5,8,7,7,0,0,7,1,2,1,2,7,7,7,4],[3,9,7,9,5,8,9,5,6,9,8,8,0,1,4,2,8,2],[1,5,2,2,2,5,6,3,9,3,1,7,9,6,8,6,8,3],[5,7,8,3,8,8,3,9,9,8,1,9,2,5,4,7,7,7],[2,3,2,4,8,5,1,7,2,9,5,2,4,2,9,2,8,7],[0,1,6,1,1,0,0,6,5,4,3,4,3,7,9,6,1,9]]
print(minPathSum(grid_01))