def translationProbability(a,l,b,m):
# a is the length of the english phras
# l is the length of the english sentence
# b is the length of the foreign phras
# m is the length of the foreign sentence
    numerator = 0.0
    for k in range(1,min(l-a,m-b)+1):
        numerator += math.factorial(k)*stirling(l-a,k)*stirling(m-b,k)
    denominator = 0.0
    for k in range(1,min(l,m)+1):
        denominator += math.factorial(k)*stirling(l,k)*stirling(m,k)
    return numerator/denominator

def stirling(l,k):
    1/k!


