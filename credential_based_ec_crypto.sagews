︠62d41ade-f125-4ff7-8cb0-839d34cd101as︠
import hashlib

def distWeil(P,Q):
    E = P.curve()
    o = max(P.order(),Q.order())
    assert (o % P.order() == 0)
    assert (o % Q.order() == 0)
    i = E.base_field().0
    new_Q = E(-Q[0],i*Q[1])
    return P.weil_pairing(new_Q, o)


def RandomBinString(n):
    if n==0:
        n=ZZ.random_element(10,1000)
    a=""
    for i in range(n):
        a=a+str(ZZ.random_element(0,2))
    return a

︡d5ec9be7-7874-4882-91d7-1de70d06e3f3︡{"done":true}
︠9946a3ef-4c3b-4eba-a56a-967e99d6965as︠
def gen_nonzero_random(o):
    rand = Zmod(o).random_element()
    while rand.is_zero(): rand = Zmod(o).random_element()
    return rand


# Input: E elliptic curve, P a point of order m
# Output: Param=[P,Ppub,n,m], s   (choose some n < 256)
def setup(E,P):
    m = P.order()
    assert(is_prime(m))
    s = gen_nonzero_random(m)
    Ppub = ZZ(s)*P
    n = 128
    return [P,Ppub,n,m], s


# Input: ID a binary string, Param the public parameters
# Output: a point in E
# see # https://www.pythoncentral.io/hashing-strings-with-python/
def Hash_H1(ID,Param):
    P, _, _, m = Param
    ID_hash = hashlib.sha256(ID).hexdigest()
    if ID_hash[0:2] != "0x": ID_hash = "0x"+ID_hash
    return P * (Integer(ID_hash) % m)


# Input: ID a binary string, s the master key, Param
# Output: the private key dID associated to the identity ID of B
def extract(ID,s,Param):
    QID = Hash_H1(ID,Param)
    return QID * ZZ(s % QID.order())


# Input: s1,s2 two binary strings of same length n
# Output: the binary string xor(s1,s2)  : for each bit, xor(0,0)=xor(1,1)=0, xor(0,1)=xor(1,0)=1
def Xor(s1,s2):
    assert(len(s1) == len(s2))
    output = ""
    for b0, b1 in zip(s1, s2):
        if b0==b1: output += "0"
        else: output += "1"
    return output



# Input: gID which lives in Fp^k for some k (you can take k=2 directly if you want), Param
# Output: a binary string of length n
def Hash_H2(gID,Param):
    return bin(int(hashlib.sha256(bin(hash(gID)).lstrip("0b")).hexdigest(), base=16)).lstrip("0b")[0:Param[2]]


# Input: the message M which is a binary string of length n, ID a binary string, Param
# Output: the ciphertext [r*P,Xor(M,H2(gID^r))] for a random integer r
def encrypt(M,ID,Param):
    P, Ppub, n, m = Param
    assert(len(M)==n)
    QID = Hash_H1(ID, Param)
    gID = distWeil(QID,Ppub)
    r = gen_nonzero_random(min(P.order(),gID.order()))
    return ZZ(r)*P, Xor(M, Hash_H2(gID**ZZ(r),Param))

# Input: C the ciphertext, the private key dID, Param
# Output: the message M
def decrypt(C,dID,Param):
    return Xor(C[1], Hash_H2(distWeil(dID,C[0]),Param))

# this shows correctness of decryption
#
# Dec(C) = Dec(Enc(M)) = Dec(C0,C1)
# C0 = r*P
# C1 = M xor H2(gID**r) = M xor H2(e(QID, Ppub)**r)
# QID = H1(ID) = P*hash256(ID)
# Ppub = s*P
# e(QID,Ppub)**r = e(P*hash256(ID),P*s)**r = e(P,P)**(s*r*hash256(ID))
#
# dID = s*QID = s*H1(ID) = s*hash256(ID)*P
# e(dID,C0) = e(s*hash256(ID)*P,r*P) = e(P,P)**(s*r*hash256(ID)) = e(QID,Ppub)**r
#
# Hence H2(e(dID,C0)) xor H2(e(QID,Ppub)**r) = 0
# C1 xor H2(e(dID,C0)) = M xor H2(e(dID,C0)) xor H2(e(QID,Ppub)**r) = M xor 0 = M
# Thus Dec(C0,C1,dID,Param) = C1 xor H2(e(dID,C0)) = M

︡33c48da7-cafa-43da-99f4-ede66b1086ce︡{"done":true}
︠1a761f15-f17e-4e35-821e-8fd4bd7b7d7as︠
K=GF(400123)
K2.<i>=GF(400123^2,modulus=x^2+1)
E=EllipticCurve(K,[1,0])
E2=E.change_ring(K2)
P=E2([391527 , 127220])
ID='0110100100101'


Param, s = setup(E2,P)
M0 = RandomBinString(Param[2])
print "original message : ",M0
C = encrypt(M0,ID,Param)
print "cyphertext       :",C[1]

sID = extract(ID,s,Param)
M1 = decrypt(C,sID,Param)
assert(M0==M1)
print "decrypted message:",M1


︡8fa6c231-cdb5-4d5c-9fa1-bbd59186af75︡{"stdout":"original message :  01000011100101011011011001000110011010101110101111010000011111101111100000011100111101110001000010100101011101101101011000101110\n"}︡{"stdout":"cyphertext       : 11100001100111111101001101010010101111110000010010010110111010010110110110100010001001010000011100100111000110110110010100000001\n"}︡{"stdout":"decrypted message: 01000011100101011011011001000110011010101110101111010000011111101111100000011100111101110001000010100101011101101101011000101110\n"}︡{"done":true}
︠4d5a0e29-5491-48b7-87ac-67c8ffd5e3c1s︠



ID='0110100100101'
ID[0:3]+"000000"+str(1)+str(0)
# ???????????????
a=K2.random_element()
a
a.parent()
b=a.polynomial()
b
b.parent()
b[0],b[1]

︡70c92248-1da0-461d-867b-c117406539b7︡{"stdout":"'01100000010'\n"}︡{"stdout":"289634*i + 289158\n"}︡{"stdout":"Finite Field in i of size 400123^2\n"}︡{"stdout":"289634*i + 289158\n"}︡{"stdout":"Univariate Polynomial Ring in i over Finite Field of size 400123\n"}︡{"stdout":"(289158, 289634)\n"}︡{"done":true}
︠c125fc4a-a9e0-4dde-a83c-aca932d819c9s︠
︡561f248e-83ff-4efb-b86a-63471cfbe111︡{"done":true}
︠cee7ec68-e343-4b51-bcbd-43eb1647e4b8︠









