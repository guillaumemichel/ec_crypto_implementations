︠aec45ed8-b78d-4164-a25b-0de7529f01dds︠

def EqLine(P,Q,R):
    if Q.is_zero():
        raise ValueError("Error: Q=0 in EqLine")

    elif P.is_zero() and R.is_zero():
        return P.curve().base_field().one()

    elif P.is_zero():
        return Q[0]-R[0]

    elif R.is_zero():
        return Q[0]-P[0]

    elif P == R:
        a1, a2, a3, a4, _ = P.curve().a_invariants()
        p = 2*P[1] + a1*P[0] + a3
        if p == 0:
            return Q[0]-P[0]
        else:
            l = (3*(P[0]** 2) + 2*a2*P[0] - a1*P[1] + a4) / p
            return Q[1]-P[1] - l*(Q[0]-P[0])
    else:
        if P[0] == R[0]:
            return Q[0]-P[0]
        else:
            l = (R[1]-P[1]) / (R[0]-P[0])
            return Q[1]-P[1] - l*(Q[0]-P[0])

# I removed the 2 functions f and g because I didn't see any purpose nor how to use them.
# Using Miller's algorithm: https://crypto.stanford.edu/miller/miller.pdf
def Miller_algo(P, Q, n):
    if Q.is_zero() or n==0:
        raise ValueError("Error: Q = 0 or n=0 in Miller_algo")

    neg_n = 0
    if n < 0:
        n = -n
        neg_n = 1

    V = P
    t = V.curve().base_field().one()
    nbits = n.bits()
    i = n.nbits() - 2
    while i > -1:
        S = 2*V
        l1 = EqLine(V, Q, V)
        l2 = EqLine(S, Q, -S)
        t = (t**2) * (l1/l2)
        V = S
        if nbits[i] == 1:
            S += P
            l1 = EqLine(V, Q, P)
            l2 = EqLine(S, Q, -S)
            t = t * (l1/l2)
            V = S
        i -= 1
    if neg_n:
        l2 = EqLine(V, Q, -V)
        t = 1 / (t*l2)
    return t

def WeilP(m, P1, P2):
    E = P1.curve()

    if not P2.curve() is E:
        raise ValueError("Error: P1 and P2 are not on the same curve")

    if not ((m * P1).is_zero() and (m * P2).is_zero()):
        raise ValueError("Error: P1 or P2 is not n-torsion")

    one = E.base_field().one()

    if P1 == P2 or P1.is_zero() or P2.is_zero():
        return one

    miller2 = Miller_algo(P2, P1, m)

    if miller2 == 0:
        return one

    miller1 = Miller_algo(P1, P2, m)
    if m.test_bit(0)%2 == 0:
        return miller1/miller2
    else:
        return -miller1/miller2


︡b2f8484a-1066-49e1-a949-0a9f740eb04a︡{"done":true}
︠174a0589-bc3d-45e6-b330-aafcc5410b06s︠

# Build an example. Note that you can verify that your function is correct using P1.weil_pairing(P2,m)

print "Examples to show that the construction of the function WeilP is correct, the examples are inspired from the web"
# examples taken from https://doc.sagemath.org/html/en/reference/curves/sage/schemes/elliptic_curves/ell_point.html
F.<a> = GF(2^5)
E = EllipticCurve(F,[0,0,1,1,1])
P = E(a^4 + 1, a^3)
Fx.<b> = GF(2^(4*5))
Ex = EllipticCurve(Fx,[0,0,1,1,1])
phi = Hom(F,Fx)(F.gen().minpoly().roots(Fx)[0][0])
Px = Ex(phi(P.xy()[0]),phi(P.xy()[1]))
O = Ex(0)
Qx = Ex(b^19 + b^18 + b^16 + b^12 + b^10 + b^9 + b^8 + b^5 + b^3 + 1, b^18 + b^13 + b^10 + b^8 + b^5 + b^4 + b^3 + b)

print WeilP(41, Px, Qx) == b^19 + b^15 + b^9 + b^8 + b^6 + b^4 + b^3 + b^2 + 1 # True expected.
print WeilP(41, Px, 17 * Px) == Fx(1) # True expected.
print WeilP(41, Px, O) == Fx(1) # True expected.
print Px.weil_pairing(Qx,41)
print WeilP(41,Px,Qx)

# WeilP(40, Px, O) # should return "Error: P1 or P2 is not n-torsion"

P,Q = EllipticCurve(GF(19^4,'a'),[-1,0]).gens()
z = P.weil_pairing(Q,360)
print z
print WeilP(360, P, Q)

# my example
print "\n\nMy example =) [it can take some time to generate the 'random' torsion point]"
F.<r> = GF(109**2)
E = EllipticCurve(F,[0,0,2,-1,2])
Fx.<s> = GF(109**4)
Ex = EllipticCurve(Fx,[0,0,2,-1,2])

k=10000
while k>=1000:
    P = E.random_element()
    phi = Hom(F,Fx)(F.gen().minpoly().roots(Fx)[0][0])
    Px = Ex(phi(P.xy()[0]),phi(P.xy()[1]))
    k = Px.order()
O = Ex(0)
ExOrd = Ex.order()

# selection of a random torsion point
Qx = 0
n = 0
while (Qx==0):
    Q = Ex.random_element()
    if (k*Q).is_zero():
        Qx = Q
        n = k
        break
    order = Q.order()
    if order < 1000 and (order*Px).is_zero():
        Qx = Q
        n = order
        break

print "Px: ", Px
print "Qx: ", Qx
print "n: ", n

print "my weilpair:         ", WeilP(n, Px, Qx)
print "sagemath's weilpair: ",Px.weil_pairing(Qx,n)

# note: I guess that my example is not perfect, but it shows that at least for some examples of "random" points, the pairing is the same
# it is not totally random, but the aim is to provide a few examples to show that my pairing provides the same results as sagmeth's
# weil paring. It was easier to get a pairing this way that getting it by hand =)
# sometimes it is possible to get a constant many times in a row, it is possible to get a polynomial, juste reload it :)

︡688fd9b4-079f-4ddd-bedb-702ae8e3b83e︡{"stdout":"Examples to show that the construction of the function WeilP is correct, the examples are inspired from the web\n"}︡{"stdout":"True\n"}︡{"stdout":"True\n"}︡{"stdout":"True\n"}︡{"stdout":"b^19 + b^15 + b^9 + b^8 + b^6 + b^4 + b^3 + b^2 + 1\n"}︡{"stdout":"b^19 + b^15 + b^9 + b^8 + b^6 + b^4 + b^3 + b^2 + 1\n"}︡{"stdout":"14*a^3 + 18*a^2 + 2*a + 11\n"}︡{"stdout":"14*a^3 + 18*a^2 + 2*a + 11\n"}︡{"stdout":"\n\nMy example =) [it can take some time to generate the 'random' torsion point]\n"}︡{"stdout":"Px:  (26*s^3 + 47*s^2 + 55*s + 90 : 8*s^3 + 48*s^2 + 84*s + 43 : 1)\n"}︡{"stdout":"Qx:  (60*s^3 + 34*s^2 + 60*s + 96 : 65*s^3 + 37*s^2 + 52*s + 52 : 1)\n"}︡{"stdout":"n:  992\n"}︡{"stdout":"my weilpair:          11*s^3 + 66*s^2 + 61*s + 27\n"}︡{"stdout":"sagemath's weilpair:  11*s^3 + 66*s^2 + 61*s + 27\n"}︡{"done":true}
︠c7cbd066-f4f4-4669-a351-781a8cfc6cf6︠









