import React, { useState, useEffect, useCallback } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import {
  X,
  Clock,
  CheckCircle2,
  RefreshCw,
  AlertCircle,
  Smartphone,
  Copy,
  Check,
  ShieldCheck,
} from 'lucide-react';
import { caregiverApi, PairingCreateResponse, PairingStatusResponse } from '../api/client';

interface ConnectPatientModalProps {
  isOpen: boolean;
  onClose: () => void;
  onPatientConnected: (patientId: string, patientName?: string) => void;
}

export const ConnectPatientModal: React.FC<ConnectPatientModalProps> = ({
  isOpen,
  onClose,
  onPatientConnected,
}) => {
  const [pairingData, setPairingData] = useState<PairingCreateResponse | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string>('');
  const [copied, setCopied] = useState<boolean>(false);
  const [secondsRemaining, setSecondsRemaining] = useState<number>(600);
  const [pairingStatus, setPairingStatus] = useState<PairingStatusResponse | null>(null);
  const [isSuccess, setIsSuccess] = useState<boolean>(false);

  // Generate pairing request
  const generateNewCode = useCallback(async () => {
    setIsLoading(true);
    setError('');
    setIsSuccess(false);
    setPairingStatus(null);
    try {
      const data = await caregiverApi.createPairingRequest();
      if (data) {
        setPairingData(data);
        setSecondsRemaining(data.expires_in_seconds || 600);
      } else {
        setError('Failed to generate connection code. Please ensure backend is running.');
      }
    } catch (err: any) {
      setError(err?.message || 'Error generating connection request');
    } finally {
      setIsLoading(false);
    }
  }, []);

  // When modal opens, generate code
  useEffect(() => {
    if (isOpen) {
      generateNewCode();
    } else {
      setPairingData(null);
      setIsSuccess(false);
    }
  }, [isOpen, generateNewCode]);

  // Countdown timer
  useEffect(() => {
    if (!isOpen || !pairingData || secondsRemaining <= 0 || isSuccess) return;

    const timer = setInterval(() => {
      setSecondsRemaining((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [isOpen, pairingData, secondsRemaining, isSuccess]);

  // Status polling every 3 seconds
  useEffect(() => {
    if (!isOpen || !pairingData || secondsRemaining <= 0 || isSuccess) return;

    const pollInterval = setInterval(async () => {
      try {
        const status = await caregiverApi.getPairingStatus(pairingData.request_id);
        if (status) {
          setPairingStatus(status);
          if (status.status === 'USED') {
            setIsSuccess(true);
            clearInterval(pollInterval);
            setTimeout(() => {
              onPatientConnected(status.patient_id || '', status.patient_name || undefined);
              onClose();
            }, 1800);
          } else if (status.status === 'EXPIRED') {
            setSecondsRemaining(0);
            clearInterval(pollInterval);
          }
        }
      } catch {
        // Polling error non-blocking
      }
    }, 3000);

    return () => clearInterval(pollInterval);
  }, [isOpen, pairingData, secondsRemaining, isSuccess, onPatientConnected, onClose]);

  const handleCopyCode = () => {
    if (!pairingData) return;
    navigator.clipboard.writeText(pairingData.short_code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (!isOpen) return null;

  const formatTimer = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const isExpired = secondsRemaining <= 0;

  return (
    <div
      className="modal-overlay"
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(15, 23, 42, 0.75)',
        backdropFilter: 'blur(6px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 9999,
        padding: '16px',
      }}
      onClick={onClose}
    >
      <div
        className="modal-card"
        style={{
          background: 'var(--bg-card, #ffffff)',
          color: 'var(--text-main, #0f172a)',
          borderRadius: '16px',
          width: '100%',
          maxWidth: '520px',
          padding: '24px 28px',
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
          border: '1px solid var(--border-subtle, #e2e8f0)',
          position: 'relative',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          style={{
            position: 'absolute',
            top: '20px',
            right: '20px',
            background: 'none',
            border: 'none',
            color: 'var(--text-muted, #64748b)',
            cursor: 'pointer',
            padding: '4px',
            borderRadius: '8px',
          }}
          aria-label="Close"
        >
          <X size={20} />
        </button>

        {/* Modal Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '6px' }}>
          <div
            style={{
              width: '42px',
              height: '42px',
              borderRadius: '12px',
              background: 'rgba(14, 116, 144, 0.12)',
              color: '#0e7490',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Smartphone size={22} />
          </div>
          <div>
            <h2 style={{ fontSize: '20px', fontWeight: 700, margin: 0 }}>
              Connect Patient App
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted, #64748b)', margin: '2px 0 0 0' }}>
              Pair patient device securely via 4-digit code or QR scanner
            </p>
          </div>
        </div>

        {/* Success State */}
        {isSuccess ? (
          <div
            style={{
              padding: '36px 20px',
              textAlign: 'center',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: '12px',
            }}
          >
            <div
              style={{
                width: '64px',
                height: '64px',
                borderRadius: '50%',
                background: '#dcfce7',
                color: '#16a34a',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <CheckCircle2 size={36} />
            </div>
            <h3 style={{ fontSize: '18px', fontWeight: 700, color: '#15803d', margin: 0 }}>
              Connected Successfully!
            </h3>
            <p style={{ fontSize: '14px', color: 'var(--text-muted, #64748b)', margin: 0 }}>
              {pairingStatus?.patient_name ? `Paired with ${pairingStatus.patient_name}` : 'Patient device authorized'}
            </p>
            <p style={{ fontSize: '12px', color: '#64748b', margin: 0 }}>
              Updating patient list and loading metrics...
            </p>
          </div>
        ) : isLoading ? (
          <div
            style={{
              padding: '48px 20px',
              textAlign: 'center',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: '12px',
            }}
          >
            <RefreshCw size={28} className="animate-spin" style={{ color: '#0e7490' }} />
            <p style={{ fontSize: '14px', color: 'var(--text-muted, #64748b)', margin: 0 }}>
              Generating secure pairing code...
            </p>
          </div>
        ) : error ? (
          <div style={{ padding: '24px 0' }}>
            <div
              style={{
                background: 'rgba(239, 68, 68, 0.1)',
                border: '1px solid rgba(239, 68, 68, 0.3)',
                borderRadius: '10px',
                padding: '14px',
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
                color: '#b91c1c',
                fontSize: '13px',
                marginBottom: '16px',
              }}
            >
              <AlertCircle size={18} />
              <span>{error}</span>
            </div>
            <button
              type="button"
              className="btn btn-primary"
              style={{ width: '100%', padding: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
              onClick={generateNewCode}
            >
              <RefreshCw size={16} />
              <span>Retry</span>
            </button>
          </div>
        ) : pairingData ? (
          <div>
            {/* Countdown bar */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                background: isExpired ? '#fef2f2' : 'var(--bg-app, #f8fafc)',
                padding: '8px 14px',
                borderRadius: '8px',
                margin: '16px 0',
                border: `1px solid ${isExpired ? '#fca5a5' : 'var(--border-subtle, #e2e8f0)'}`,
                fontSize: '13px',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: isExpired ? '#dc2626' : 'var(--text-muted, #64748b)' }}>
                <Clock size={15} />
                <span>{isExpired ? 'Code Expired' : 'Code valid for:'}</span>
              </div>
              <span
                style={{
                  fontFamily: 'monospace',
                  fontWeight: 700,
                  fontSize: '14px',
                  color: isExpired ? '#dc2626' : secondsRemaining < 60 ? '#d97706' : '#0e7490',
                }}
              >
                {formatTimer(secondsRemaining)}
              </span>
            </div>

            {isExpired ? (
              <div style={{ textAlign: 'center', padding: '24px 0' }}>
                <p style={{ color: '#dc2626', fontSize: '14px', marginBottom: '16px' }}>
                  This pairing request has expired for security.
                </p>
                <button
                  type="button"
                  className="btn btn-primary"
                  onClick={generateNewCode}
                  style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '10px 20px' }}
                >
                  <RefreshCw size={16} />
                  <span>Generate New Pairing Code</span>
                </button>
              </div>
            ) : (
              <>
                {/* Method 1: Big 4-Digit Code */}
                <div
                  style={{
                    background: 'var(--bg-app, #f8fafc)',
                    border: '2px dashed var(--border-strong, #cbd5e1)',
                    borderRadius: '12px',
                    padding: '16px',
                    textAlign: 'center',
                    marginBottom: '16px',
                  }}
                >
                  <div style={{ fontSize: '12px', textTransform: 'uppercase', letterSpacing: '0.08em', color: 'var(--text-muted, #64748b)', marginBottom: '6px', fontWeight: 600 }}>
                    Method 1: 4-Digit Connection Code
                  </div>
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      gap: '12px',
                      fontSize: '38px',
                      fontWeight: 800,
                      fontFamily: 'monospace',
                      letterSpacing: '0.25em',
                      color: '#0e7490',
                      margin: '4px 0 10px 0',
                    }}
                  >
                    {pairingData.short_code}
                  </div>
                  <button
                    type="button"
                    onClick={handleCopyCode}
                    style={{
                      background: 'var(--bg-card, #ffffff)',
                      border: '1px solid var(--border-subtle, #e2e8f0)',
                      borderRadius: '6px',
                      padding: '5px 12px',
                      fontSize: '12px',
                      cursor: 'pointer',
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '6px',
                      color: copied ? '#16a34a' : 'var(--text-muted, #64748b)',
                    }}
                  >
                    {copied ? <Check size={14} /> : <Copy size={14} />}
                    <span>{copied ? 'Copied' : 'Copy Code'}</span>
                  </button>
                </div>

                {/* Method 2: QR Code */}
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '20px',
                    padding: '14px',
                    background: 'var(--bg-app, #f8fafc)',
                    borderRadius: '12px',
                    border: '1px solid var(--border-subtle, #e2e8f0)',
                    marginBottom: '16px',
                  }}
                >
                  <div
                    style={{
                      background: '#ffffff',
                      padding: '8px',
                      borderRadius: '8px',
                      boxShadow: '0 2px 6px rgba(0,0,0,0.08)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0,
                    }}
                  >
                    <QRCodeSVG
                      value={pairingData.qr_payload}
                      size={110}
                      level="M"
                      includeMargin={false}
                    />
                  </div>
                  <div>
                    <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-main, #0f172a)', marginBottom: '4px' }}>
                      Method 2: In-App QR Scanner
                    </div>
                    <p style={{ fontSize: '12px', color: 'var(--text-muted, #64748b)', margin: '0 0 6px 0', lineHeight: 1.4 }}>
                      Open the BANDHU patient app on mobile, tap <strong>Scan QR</strong> under Caregiver Connection, and point the camera here.
                    </p>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', color: '#0e7490' }}>
                      <ShieldCheck size={13} />
                      <span>End-to-end encrypted connection</span>
                    </div>
                  </div>
                </div>

                {/* Live Polling Indicator */}
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                    padding: '8px',
                    fontSize: '12px',
                    color: 'var(--text-muted, #64748b)',
                  }}
                >
                  <span
                    style={{
                      width: '8px',
                      height: '8px',
                      borderRadius: '50%',
                      background: '#0e7490',
                      animation: 'pulse 1.5s infinite',
                      display: 'inline-block',
                    }}
                  />
                  <span>Waiting for patient confirmation on device...</span>
                </div>
              </>
            )}
          </div>
        ) : null}

        {/* Footer info */}
        <div
          style={{
            marginTop: '16px',
            paddingTop: '12px',
            borderTop: '1px solid var(--border-subtle, #e2e8f0)',
            display: 'flex',
            justifyContent: 'flex-end',
          }}
        >
          <button
            type="button"
            className="btn btn-secondary"
            onClick={onClose}
            style={{ padding: '8px 16px', fontSize: '13px' }}
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};
