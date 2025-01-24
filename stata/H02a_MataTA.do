mata
// Compute time-aggregation correction
X = .
L = .
eigensystem(T, X, L)
S = X*diag(log(L))*luinv(X)

// Discard values in the diagonal
_diag(S,.)

// Check eigenvalues are positive and real
if ((min(Im(L):==0) == 1) & (min(Re(L):>0) == 1)) {
  R = Re(S)
}
else {
  R = J(rows(S), cols(S), .)
}

// Transform return matrix into vector
R = vec(R')'
end
