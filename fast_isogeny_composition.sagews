︠f7671d7b-a64e-4239-811a-2c4c8ccbf947s︠
# Input: R0 a point of order l^e in the elliptic curve E
# Output: the isogenous curve E/<P>, the path of the intermediate elliptic curves, Phi the intermediate isogenies
#  multiplication-based algorithm
def IsogPrimePower_1(R0):
    E=R0.curve()
    F=R0.order().factor()
    l=F[0][0]; e=F[0][1]

    P = R0
    Phi = list()
    Path = [E]
    for i in range(e-1):
        Phi.append(P.curve().isogeny(l**(e-i-1)*P))
        P = Phi[i](P)
        Path.append(P.curve())

    return Path[-1],Path[:-1],Phi

# Input: Phi path of isogenies, P point of E
# Output: the image of P
def EvaluateIsog(Phi,P):
    for i in range(len(Phi)):
        P=Phi[i](P)
    return P


︡bbb3e48b-db02-4ee6-8b0a-0df8cdd78309︡{"done":true}
︠ae3dfb7e-3b9b-4f0f-bc89-312eb9e267ees︠
# build array to store results for DP
# ok if p, q are not modified
mem = {}
mem[0] = (0,0)
mem[1] = (0,0)


# Input: n,p,q integers
# Output: C_p,q(n) and the i giving the minimal value
def Cpqn(n,p,q): # parce que pourquoi les mettre dans le meme ordre ? xD
    def recursion(n,p,q):
        # if already computed
        if n in mem: return mem[n]

        min_res = oo
        min_i = 0
        for i in range(1,n):
            tmp = recursion(i,p,q)[0] + recursion(n-i,p,q)[0] + (n-i)*p + i*q
            if (tmp < min_res):
                min_res = tmp
                min_i = i

        # write the freshly computed value in the array
        mem[n] = (min_res, min_i)
        return (min_res, min_i)

    return recursion(n,p,q)


# Input: R0 a point of order l^e, e, l
# Output: the leaves of Tn. You have to use the function Cpqn ...
# I added p, q in the parameter list as there is no indication on how to get them
def Leaves(R0,e,l, p, q):
    leaves = list()
    P = R0
    phis = list()
    for j in range(e-1):
        phis.append(P.curve().isogeny(l**(e-j-1)*P))
        P = phis[j](P)
    j = 0

    def recursionL(R, n,j):
        if n == 1:
            leaves.append(R)
        else:
            i = Cpqn(n,p,q)[1]

            # left part
            R_l = l**(n-i)*R
            recursionL(R_l, i, j)

            # right part
            R_r = R
            for _ in range(i):
                R_r = phis[j](R_r)
                j += 1
            recursionL(R_r, n-i, j)

    recursionL(R0, e, j)
    return (leaves,phis)



# Input: R0 a point of order l^e, e, l
# Output: the leaves of Tn. This function allows you to verify the result of the function "Leaves"
def VerifyLeaves(R0,e,l):
    R=[R0]
    for i in range(e):
    	r=R[-1]
    	phi=r.curve().isogeny(l^(e-1-i)*r)
	R=R+[phi(r)]
    return [l^(e-1-i)*R[i] for i in range(e)]


# Input: R0 a point of order l^e in the elliptic curve E
# Output: the isogenous curve E/<P>, the path of the intermediate elliptic curves, Phi the intermediate isogenies
# find an optimal strategy in Te for this algorithm
def IsogPrimePower_2(R0):
    E=R0.curve()
    F=R0.order().factor()
    l=F[0][0]; e=F[0][1]

    p = 2
    q = 3
    (leaves,Phi) = Leaves(R0, e, l, p, q)

    Path = list()

    for i in range(len(leaves)-1):
        P = leaves[i]
        E = P.curve()
        Path.append(E)
        #Phi.append(R0.curve().isogeny(l**(e-i-1)*R0))
        #R0 = Phi[i](R0)
        # to avoid computing it again, it is returned by Leaves

    E = leaves[-1].curve()
    return E,Path,Phi

︡33acefec-8e2e-4e00-ac0a-32d8e58bd513︡{"done":true}
︠59c12196-8b60-4937-926b-4b3a2bc8088es︠

# Example of the computation of an isogeny with Sage

E=EllipticCurve(GF(1009),[514,495])
E.order().factor()
P=E(0)
while P==E(0):
      P=10*E.random_element()
phi=E.isogeny(P)
phi
E2=phi.codomain()  # isogenous elliptic curve
E2
Q=E.random_element() # image of a point
R=phi(Q)
Q,R
R in E2

︡140707b0-f447-4285-ac32-f860ad25de68︡{"stdout":"2 * 5 * 101\n"}︡{"stdout":"Isogeny of degree 101 from Elliptic Curve defined by y^2 = x^3 + 514*x + 495 over Finite Field of size 1009 to Elliptic Curve defined by y^2 = x^3 + 916*x + 155 over Finite Field of size 1009\n"}︡{"stdout":"Elliptic Curve defined by y^2 = x^3 + 916*x + 155 over Finite Field of size 1009\n"}︡{"stdout":"((660 : 837 : 1), (557 : 658 : 1))\n"}︡{"stdout":"True\n"}︡{"done":true}
︠4dc51875-6b07-44e0-9a09-d91757a55a3bs︠


import time

p=2^17*3^8*89+1
K.<a>=GF(p^2,modulus=x^2+x+2)
E=EllipticCurve(K,[20605319650*a+57726606895,19374961692*a+283707633])
E.order()==(p-1)^2


#t=time.time()
#F1,Path1,Phi1=IsogPrimePower_1(P)
#print "Temps calcul 1:",time.time()-t
#t=time.time()
#F2,Path2,Phi2=IsogPrimePower_2(P)
#print "Temps calcul 2:",time.time()-t

# Note: you can use modular polynomial to verify the intermediate curves

︡4daa0b46-732b-4776-9c3a-e766a8e6c3a0︡{"stdout":"True\n"}︡{"done":true}
︠4abb2651-68bf-4d66-acb4-bcd17d41ebd9s︠
#Cpqn(4,2,3) # the limit for n is 987
Q = E.random_point()
o = Q.order()
(l,e) = o.factor()[0]
m = o/(l**e)
R0 = ZZ(m)*Q
#print R0

print Leaves(R0, e, l, 2, 3)[0] == VerifyLeaves(R0, e, l)

︡138a5432-71a1-4116-b4d3-114a33bba736︡{"stdout":"True"}︡{"stdout":"\n"}︡{"done":true}
︠7d39c09e-6cae-4033-9232-8efbe1c3026cs︠
print IsogPrimePower_1(R0)==IsogPrimePower_2(R0)

︡27e71c8a-2e56-41cd-b8e1-b264be91ddb6︡{"stdout":"True"}︡{"stdout":"\n"}︡{"done":true}
︠80a45f38-974a-4ea0-b778-0b400cf29bf3s︠
iterations = 20

t=time.time()
for _ in range(iterations):
    _ = IsogPrimePower_1(R0)
print "Temps calcul 1:",(time.time()-t)/iterations
t=time.time()
for _ in range(iterations):
    _ = IsogPrimePower_2(R0)
print "Temps calcul 2:",(time.time()-t)/iterations
︡f5d26c07-97a0-497b-8f38-bd0b50e3f199︡{"stdout":"Temps calcul 1: 0.0385014414787\n"}︡{"stdout":"Temps calcul 2: 0.0638175964355\n"}︡{"done":true}
︠9ffe043f-2c00-4a53-84b6-456ad2f206a9︠














