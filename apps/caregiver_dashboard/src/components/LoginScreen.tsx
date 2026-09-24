import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { HeartHandshake, UserPlus, LogIn, AlertCircle } from 'lucide-react';

export const LoginScreen: React.FC = () => {
  const { login, register } = useAuth();
  const [isRegister, setIsRegister] = useState<boolean>(false);
  const [email, setEmail] = useState<string>('');
  const [password, setPassword] = useState<string>('');
  const [fullName, setFullName] = useState<string>('');
  const [relationship, setRelationship] = useState<string>('Family Caregiver');
  const [phone, setPhone] = useState<string>('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      if (isRegister) {
        if (!fullName.trim()) {
          setError('Please provide your full name.');
          setLoading(false);
          return;
        }
        await register({
          email,
          password,
          full_name: fullName,
          relationship_to_patient: relationship,
          phone_number: phone || undefined,
        });
      } else {
        await login(email, password);
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed. Please verify your credentials.');
    } finally {
      setLoading(false);
    }
  };

  const inputStyle: React.CSSProperties = {
    width: '100%',
    padding: '11px 14px',
    borderRadius: '8px',
    border: '1px solid var(--border-subtle)',
    fontSize: '14px',
    outline: 'none',
    boxSizing: 'border-box',
    background: 'var(--bg-surface)',
    color: 'var(--text-main)',
  };

  const labelStyle: React.CSSProperties = {
    display: 'block',
    fontSize: '13px',
    fontWeight: 600,
    color: 'var(--text-main)',
    marginBottom: '6px',
  };

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'var(--bg-app)', padding: '24px' }}>
      <div style={{ width: '100%', maxWidth: '420px', backgroundColor: 'var(--bg-surface)', borderRadius: '16px', border: '1px solid var(--border-subtle)', boxShadow: '0 8px 30px rgba(0,0,0,0.06)', padding: '36px 32px' }}>
        {/* Brand Header */}
        <div style={{ textAlign: 'center', marginBottom: '28px' }}>
          <img
            src="/assets/branding/bandhu_logo.png"
            alt="BANDHU — AI Cognitive Care Companion"
            style={{
              width: '130px',
              height: '130px',
              objectFit: 'contain',
              borderRadius: '20px',
              marginBottom: '14px',
              boxShadow: '0 4px 16px rgba(15, 76, 92, 0.08)',
            }}
          />
          <h1 style={{ fontSize: '24px', fontWeight: 'bold', letterSpacing: '0.02em', color: 'var(--text-main)', margin: 0 }}>
            BANDHU
          </h1>
          <div style={{ fontSize: '13.5px', fontWeight: 600, color: '#0F4C5C', marginTop: '4px', letterSpacing: '0.04em' }}>
            AI Cognitive Care Companion
          </div>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginTop: '6px' }}>
            {isRegister ? 'Caregiver Registration & Transparency Portal' : 'Caregiver Portal • Sign in to access synchronized activity monitoring'}
          </p>
        </div>

        {/* Mode Switcher */}
        <div style={{ display: 'flex', backgroundColor: 'var(--bg-app)', borderRadius: '10px', padding: '4px', marginBottom: '24px' }}>
          <button
            type="button"
            onClick={() => { setIsRegister(false); setError(null); }}
            style={{
              flex: 1,
              padding: '9px',
              border: 'none',
              borderRadius: '8px',
              fontWeight: 600,
              fontSize: '14px',
              cursor: 'pointer',
              backgroundColor: !isRegister ? 'var(--bg-surface)' : 'transparent',
              color: !isRegister ? 'var(--text-main)' : 'var(--text-muted)',
              boxShadow: !isRegister ? '0 2px 6px rgba(0,0,0,0.05)' : 'none',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
            }}
          >
            <LogIn size={15} /> Sign In
          </button>
          <button
            type="button"
            onClick={() => { setIsRegister(true); setError(null); }}
            style={{
              flex: 1,
              padding: '9px',
              border: 'none',
              borderRadius: '8px',
              fontWeight: 600,
              fontSize: '14px',
              cursor: 'pointer',
              backgroundColor: isRegister ? 'var(--bg-surface)' : 'transparent',
              color: isRegister ? 'var(--text-main)' : 'var(--text-muted)',
              boxShadow: isRegister ? '0 2px 6px rgba(0,0,0,0.05)' : 'none',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
            }}
          >
            <UserPlus size={15} /> Register
          </button>
        </div>

        {error && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', backgroundColor: '#FEF2F2', border: '1px solid #FCA5A5', color: '#B91C1C', padding: '12px 14px', borderRadius: '10px', marginBottom: '20px', fontSize: '14px' }}>
            <AlertCircle size={18} style={{ flexShrink: 0 }} />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {isRegister && (
            <div>
              <label style={labelStyle}>Full Name</label>
              <input
                type="text"
                required
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                placeholder="e.g. Priya Sharma"
                style={inputStyle}
              />
            </div>
          )}

          <div>
            <label style={labelStyle}>Email Address</label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="caregiver@example.com"
              style={inputStyle}
            />
          </div>

          <div>
            <label style={labelStyle}>Password</label>
            <input
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              style={inputStyle}
            />
          </div>

          {isRegister && (
            <>
              <div>
                <label style={labelStyle}>Relationship to Patient</label>
                <select
                  value={relationship}
                  onChange={(e) => setRelationship(e.target.value)}
                  style={{ ...inputStyle }}
                >
                  <option value="Family Caregiver">Family Caregiver</option>
                  <option value="Daughter">Daughter</option>
                  <option value="Son">Son</option>
                  <option value="Spouse">Spouse</option>
                  <option value="Sibling">Sibling</option>
                  <option value="Professional Nurse / Caregiver">Professional Nurse / Caregiver</option>
                </select>
              </div>

              <div>
                <label style={labelStyle}>Phone Number (Optional)</label>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+91 98765 43210"
                  style={inputStyle}
                />
              </div>
            </>
          )}

          {/* Primary Sign In Button — strong contrast */}
          <button
            type="submit"
            disabled={loading}
            style={{
              marginTop: '8px',
              padding: '12px',
              backgroundColor: '#3b7a57',
              color: '#FFFFFF',
              border: 'none',
              borderRadius: '10px',
              fontSize: '15px',
              fontWeight: 700,
              cursor: loading ? 'not-allowed' : 'pointer',
              opacity: loading ? 0.65 : 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              transition: 'background 0.15s ease',
            }}
            onMouseEnter={(e) => {
              if (!loading) (e.currentTarget.style.backgroundColor = '#2d5e43');
            }}
            onMouseLeave={(e) => {
              (e.currentTarget.style.backgroundColor = '#3b7a57');
            }}
          >
            {loading ? 'Please wait...' : (isRegister ? 'Register as Caregiver' : 'Sign In')}
          </button>
        </form>

        <div style={{ marginTop: '24px', paddingTop: '18px', borderTop: '1px solid var(--border-subtle)', textAlign: 'center', fontSize: '13px', color: 'var(--text-muted)' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px', color: 'var(--color-sage, #3b7a57)', fontWeight: 600, marginBottom: '4px' }}>
            <HeartHandshake size={16} /> BANDHU
          </div>
          Patient data is secure and only accessible by authorized caregivers.
        </div>
      </div>
    </div>
  );
};
