︠17f62357-e96a-4894-ab7f-03ed818cf483s︠
p=59
F.<i> = GF(p^2, modulus=x^2+1)
E = EllipticCurve(F, [1,0])
assert (p % 4 == 3)

def distWeil(P,Q):
    o = max(P.order(),Q.order())
    assert (o % P.order() == 0)
    assert (o % Q.order() == 0)
    new_Q = Q
    i = E.base_field().0
    new_Q = E(-Q[0],i*Q[1])

    return P.weil_pairing(new_Q, o)

P = E(25,30)

print "e_(phi)(P,P):   ", distWeil(P,P)
print "e_(phi)(P,P)^m: ",distWeil(P,P)**P.order()

︡22900ced-0e7a-4440-8aca-b93ae6158455︡{"stdout":"e_(phi)(P,P):    56*i + 46\n"}︡{"stdout":"e_(phi)(P,P)^m:  1\n"}︡{"done":true}
︠1cf67faf-286b-4edd-94aa-d2400c148945s︠
def gen_nonzero_random(o):
    rand = Zmod(o).random_element()
    while rand.is_zero(): rand = Zmod(o).random_element()
    return rand

def keygen(E,P):
    ska = gen_nonzero_random(P.order())
    pka = P * ZZ(ska)
    return (ska, pka)

def reenc(ska,pkb):
    return inverse_mod(ZZ(ska),ska.modulus())*pkb

def encrypt_level1(M,P,pka):
    Z = distWeil(P,P)
    r = gen_nonzero_random(Z.order())
    return distWeil(pka,P)**r, M*(Z**r)

def encrypt_level2(M,P,pka):
    Z = distWeil(P,P)
    r = gen_nonzero_random(Z.order())
    return (ZZ(r)*pka,M*(Z**r))

def reencrypt(c2,rkab):
    return (distWeil(c2[0],rkab), c2[1])

def decrypt_level1(c1,ska):
    Z = c1[0]**(inverse_mod(ZZ(ska),ska.modulus()))
    return c1[1] * Z**(-1)
︡147966bc-9df5-40b0-9547-28e3281a5303︡{"done":true}
︠3e4624bf-edb7-480f-9b63-73a5703c1216s︠
M0 = F.random_element(); M0

(ska, pka) = keygen(E, P)
(skb, pkb) = keygen(E, P)

c1 = encrypt_level1(M0, P, pka);
c2 = encrypt_level2(M0, P, pka);

M1 = decrypt_level1(c1, ska); M1

rkab = reenc(ska, pkb)
c1R = reencrypt(c2, rkab)

M2 = decrypt_level1(c1R, skb); M2
︡6a8d2c9e-01da-4425-9e54-0c5f838aeb8d︡{"stdout":"14*i + 4\n"}︡{"stdout":"14*i + 4\n"}︡{"stdout":"14*i + 4\n"}︡{"done":true}
︠0cd581fa-71be-47eb-90c7-9ee44f897afa︠










