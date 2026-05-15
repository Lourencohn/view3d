// tab-screens.jsx — Telas das abas do bottom nav:
// Compartilhados, Insights, Conta. Cada uma usa o mesmo "app-scroll".

// ─────────────────────────────────────────────────────────────
// Shared utilities
// ─────────────────────────────────────────────────────────────
function findProduto(id) {
  return PRODUCTS.find(p => p.id === id);
}

function CanalDot({ canal, size = 8 }) {
  const c = CANAIS[canal];
  if (!c) return null;
  return (
    <span style={{
      display: 'inline-block', width: size, height: size,
      borderRadius: '50%', background: c.color,
    }}/>
  );
}

function CanalChip({ canal }) {
  const c = CANAIS[canal];
  if (!c) return null;
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '3px 8px', borderRadius: 999,
      background: 'var(--bg-muted)',
      fontSize: 11, fontWeight: 500, color: 'var(--ink-2)',
    }}>
      <CanalDot canal={canal} size={6}/>
      {c.label}
    </span>
  );
}

function MiniThumb({ produto, size = 48, radius = 12 }) {
  if (!produto) return null;
  return (
    <div style={{
      width: size, height: size, borderRadius: radius,
      background: `radial-gradient(circle at 50% 50%, #fff 0%, ${produto.accent}55 100%)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0, overflow: 'hidden',
    }}>
      <span style={{
        fontFamily: 'var(--font-display)', fontStyle: 'italic',
        fontSize: size * 0.42, color: 'rgba(26,24,21,0.4)',
        letterSpacing: '-0.02em',
      }}>
        {produto.nome[0]}
      </span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 1) Compartilhados
// ─────────────────────────────────────────────────────────────
function CompartilhadosScreen({ onOpen, onGo }) {
  const [filtro, setFiltro] = React.useState('todos');

  const lista = SHARES.filter(s =>
    filtro === 'todos' ? true : s.canal === filtro
  );

  // Agrupa por dia
  const grouped = lista.reduce((acc, s) => {
    const k = dayBucket(s.dataHora);
    (acc[k] = acc[k] || []).push(s);
    return acc;
  }, {});

  const totalViews = SHARES.reduce((a, s) => a + s.views, 0);
  const totalArSessions = SHARES.reduce((a, s) => a + s.arSessions, 0);

  return (
    <div className="app-scroll">
      <div className="topbar-pad"/>

      <div className="cat-header">
        <div className="cat-eyebrow">Atividade</div>
        <h1 className="cat-title">Compartilhados</h1>
        <div style={{
          display: 'flex', gap: 22, marginTop: 10,
          fontSize: 12, color: 'var(--ink-3)', fontVariantNumeric: 'tabular-nums',
        }}>
          <div><b style={{ color: 'var(--ink)', fontWeight: 500, fontSize: 14 }}>
            {SHARES.length}
          </b> envios · 7 dias</div>
          <div><b style={{ color: 'var(--ink)', fontWeight: 500, fontSize: 14 }}>
            {totalViews}
          </b> views</div>
          <div><b style={{ color: 'var(--accent)', fontWeight: 500, fontSize: 14 }}>
            {totalArSessions}
          </b> AR</div>
        </div>
      </div>

      <div className="cat-filters">
        {[
          ['todos', 'Todos'],
          ['whatsapp', 'WhatsApp'],
          ['email', 'E-mail'],
          ['qr', 'QR'],
          ['link', 'Link'],
        ].map(([k, label]) => (
          <button key={k} className="cat-chip"
                  data-on={k === filtro ? '1' : '0'}
                  onClick={() => setFiltro(k)}>
            {label}
          </button>
        ))}
      </div>

      <div style={{ padding: '4px 16px 100px' }}>
        {Object.entries(grouped).map(([bucket, items]) => (
          <div key={bucket} style={{ marginBottom: 18 }}>
            <div style={{
              padding: '8px 4px 10px',
              fontSize: 11, textTransform: 'uppercase',
              letterSpacing: '0.16em', color: 'var(--ink-3)',
              fontWeight: 500,
            }}>{bucket}</div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
              {items.map(s => {
                const p = findProduto(s.produtoId);
                if (!p) return null;
                return (
                  <button key={s.id}
                          onClick={() => onOpen && onOpen(p)}
                          style={{
                            display: 'flex', alignItems: 'center', gap: 12,
                            padding: 10, borderRadius: 14,
                            background: 'var(--bg-card)',
                            border: 0, cursor: 'pointer', width: '100%',
                            textAlign: 'left',
                            boxShadow: 'var(--sh-1)',
                          }}>
                    <MiniThumb produto={p} size={48}/>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{
                        fontSize: 14, fontWeight: 500,
                        color: 'var(--ink)', letterSpacing: '-0.01em',
                        whiteSpace: 'nowrap', overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}>{p.nome}</div>
                      <div style={{
                        fontSize: 12, color: 'var(--ink-3)',
                        marginTop: 2, display: 'flex', alignItems: 'center', gap: 6,
                      }}>
                        <CanalDot canal={s.canal} size={6}/>
                        <span style={{
                          whiteSpace: 'nowrap', overflow: 'hidden',
                          textOverflow: 'ellipsis', minWidth: 0,
                        }}>
                          {s.comprador || s.contato || CANAIS[s.canal].label}
                        </span>
                        <span style={{ color: 'var(--ink-4)' }}>·</span>
                        <span>{relTime(s.dataHora)}</span>
                      </div>
                    </div>

                    <div style={{
                      display: 'flex', flexDirection: 'column',
                      alignItems: 'flex-end', gap: 2,
                      fontVariantNumeric: 'tabular-nums',
                    }}>
                      <div style={{
                        fontSize: 14, fontWeight: 500,
                        color: 'var(--ink)',
                      }}>{s.views}</div>
                      <div style={{
                        fontSize: 10, color: 'var(--ink-3)',
                        textTransform: 'uppercase', letterSpacing: '0.08em',
                      }}>views</div>
                      {s.arSessions > 0 && (
                        <div style={{
                          marginTop: 2, fontSize: 10,
                          color: 'var(--accent)', fontWeight: 500,
                          letterSpacing: '0.04em',
                        }}>+{s.arSessions} AR</div>
                      )}
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      <TabBar active="shared" onGo={onGo}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 2) Insights
// ─────────────────────────────────────────────────────────────
function Sparkbars({ data, height = 80, color = 'var(--ink)', accent }) {
  const max = Math.max(...data, 1);
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-end', gap: 6,
      height, padding: '2px 0',
    }}>
      {data.map((v, i) => {
        const isLast = i === data.length - 1;
        const h = Math.max(4, (v / max) * (height - 4));
        return (
          <div key={i} style={{
            flex: 1, height: h, borderRadius: 4,
            background: isLast ? (accent || 'var(--accent)') : color,
            opacity: isLast ? 1 : 0.18,
            transition: 'height .3s ease',
          }}/>
        );
      })}
    </div>
  );
}

function DeltaPill({ value }) {
  const pos = value >= 0;
  const v = Math.round(value * 100);
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 3,
      padding: '2px 7px', borderRadius: 999,
      background: pos ? '#dbf2e6' : '#fde0db',
      color: pos ? '#1f8a5b' : '#c93f2a',
      fontSize: 11, fontWeight: 500,
      fontVariantNumeric: 'tabular-nums',
      whiteSpace: 'nowrap',
      flexShrink: 0,
    }}>
      {pos ? '↑' : '↓'} {Math.abs(v)}%
    </span>
  );
}

function StatTile({ label, value, delta, accent = false, suffix }) {
  return (
    <div style={{
      background: 'var(--bg-card)', borderRadius: 16,
      padding: '14px 16px', display: 'flex', flexDirection: 'column',
      gap: 6, boxShadow: 'var(--sh-1)', minWidth: 0,
    }}>
      <div style={{
        fontSize: 10, textTransform: 'uppercase',
        letterSpacing: '0.08em', color: 'var(--ink-3)',
        fontWeight: 500,
        whiteSpace: 'nowrap',
        overflow: 'hidden', textOverflow: 'ellipsis',
      }}>{label}</div>
      <div style={{
        display: 'flex', alignItems: 'baseline', gap: 6,
        flexWrap: 'wrap',
      }}>
        <div style={{
          fontFamily: 'var(--font-display)',
          fontSize: 30, lineHeight: 1, letterSpacing: '-0.015em',
          color: accent ? 'var(--accent)' : 'var(--ink)',
          fontVariantNumeric: 'tabular-nums',
        }}>{value}{suffix ? <span style={{
          fontFamily: 'var(--font-sans)', fontSize: 14,
          color: 'var(--ink-3)', marginLeft: 2,
        }}>{suffix}</span> : null}</div>
        {delta != null && <DeltaPill value={delta}/>}
      </div>
    </div>
  );
}

function InsightsScreen({ onOpen, onGo }) {
  const I = INSIGHTS;

  // % bars
  const canaisArr = Object.entries(I.canais)
    .sort(([, a], [, b]) => b - a);

  return (
    <div className="app-scroll">
      <div className="topbar-pad"/>

      <div className="cat-header">
        <div className="cat-eyebrow">Últimos 7 dias</div>
        <h1 className="cat-title">Insights</h1>
      </div>

      <div style={{
        padding: '0 16px 100px',
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        {/* Hero card — views grandes + sparkbars */}
        <div style={{
          background: 'var(--bg-card)', borderRadius: 20,
          padding: '20px 20px 16px',
          boxShadow: 'var(--sh-1)',
        }}>
          <div style={{
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            gap: 8,
          }}>
            <div style={{
              fontSize: 10, textTransform: 'uppercase',
              letterSpacing: '0.12em', color: 'var(--ink-3)',
              fontWeight: 500, whiteSpace: 'nowrap',
            }}>Total de views</div>
            <DeltaPill value={I.views7dDelta}/>
          </div>
          <div style={{
            display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 4,
          }}>
            <div style={{
              fontFamily: 'var(--font-display)',
              fontSize: 56, lineHeight: 1,
              letterSpacing: '-0.025em', color: 'var(--ink)',
              fontVariantNumeric: 'tabular-nums',
            }}>{I.views7d}</div>
            <div style={{
              fontFamily: 'var(--font-display)', fontSize: 24,
              color: 'var(--ink-4)', fontStyle: 'italic',
            }}>vs <span style={{ textDecoration: 'line-through' }}>
              {Math.round(I.views7d / (1 + I.views7dDelta))}
            </span></div>
          </div>

          <div style={{ marginTop: 14 }}>
            <Sparkbars data={I.viewsSeries} height={70}/>
          </div>
          <div style={{
            display: 'flex', justifyContent: 'space-between',
            fontSize: 10, color: 'var(--ink-3)',
            letterSpacing: '0.04em', textTransform: 'uppercase',
            marginTop: 6, fontWeight: 500,
          }}>
            {['7d', '6d', '5d', '4d', '3d', '2d', 'hoje'].map((d, i) => (
              <div key={i} style={{
                flex: 1, textAlign: 'center',
                color: i === 6 ? 'var(--ink-2)' : 'var(--ink-3)',
                fontWeight: i === 6 ? 600 : 500,
              }}>{d}</div>
            ))}
          </div>
        </div>

        {/* Stats grid */}
        <div style={{
          display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10,
        }}>
          <StatTile label="Compradores únicos"
                    value={I.uniqueBuyers}
                    delta={I.uniqueBuyersDelta}/>
          <StatTile label="Sessões AR"
                    value={I.arSessions}
                    delta={I.arSessionsDelta}
                    accent/>
          <StatTile label="Tempo médio"
                    value={I.avgTimeSec}
                    suffix="s"
                    delta={I.avgTimeDelta}/>
          <StatTile label="Taxa AR"
                    value={Math.round(I.arSessions / I.views7d * 100)}
                    suffix="%"/>
        </div>

        {/* Top produtos */}
        <div style={{
          background: 'var(--bg-card)', borderRadius: 20,
          padding: '16px 18px', boxShadow: 'var(--sh-1)',
        }}>
          <div style={{
            display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
            marginBottom: 12,
          }}>
            <div style={{
              fontSize: 11, textTransform: 'uppercase',
              letterSpacing: '0.16em', color: 'var(--ink-3)',
              fontWeight: 500,
            }}>Top produtos</div>
            <div style={{ fontSize: 11, color: 'var(--ink-4)' }}>views · AR</div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            {I.topProdutos.map((row, i) => {
              const p = findProduto(row.id);
              if (!p) return null;
              const maxViews = I.topProdutos[0].views;
              return (
                <button key={row.id}
                        onClick={() => onOpen && onOpen(p)}
                        style={{
                          display: 'flex', alignItems: 'center', gap: 12,
                          padding: '8px 4px', borderRadius: 10,
                          background: 'transparent', border: 0,
                          cursor: 'pointer', width: '100%', textAlign: 'left',
                        }}>
                  <div style={{
                    width: 18, fontSize: 11, color: 'var(--ink-3)',
                    fontFamily: 'var(--font-mono)', fontWeight: 500,
                  }}>{String(i + 1).padStart(2, '0')}</div>
                  <MiniThumb produto={p} size={36} radius={9}/>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{
                      fontSize: 13, fontWeight: 500,
                      color: 'var(--ink)', letterSpacing: '-0.01em',
                      whiteSpace: 'nowrap', overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}>{p.nome}</div>
                    {/* mini bar */}
                    <div style={{
                      marginTop: 4, height: 3,
                      background: 'var(--bg-muted)', borderRadius: 2,
                      overflow: 'hidden',
                    }}>
                      <div style={{
                        height: '100%', width: `${row.views / maxViews * 100}%`,
                        background: 'var(--ink)', borderRadius: 2,
                      }}/>
                    </div>
                  </div>
                  <div style={{
                    fontSize: 13, fontWeight: 500, color: 'var(--ink)',
                    fontVariantNumeric: 'tabular-nums', width: 28, textAlign: 'right',
                  }}>{row.views}</div>
                  <div style={{
                    fontSize: 12, color: 'var(--accent)', fontWeight: 500,
                    fontVariantNumeric: 'tabular-nums', width: 26, textAlign: 'right',
                  }}>{row.arSessions}</div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Canais */}
        <div style={{
          background: 'var(--bg-card)', borderRadius: 20,
          padding: '16px 18px', boxShadow: 'var(--sh-1)',
        }}>
          <div style={{
            fontSize: 11, textTransform: 'uppercase',
            letterSpacing: '0.16em', color: 'var(--ink-3)',
            fontWeight: 500, marginBottom: 12,
          }}>Por onde compartilha</div>

          {/* stacked horizontal bar */}
          <div style={{
            display: 'flex', height: 10, borderRadius: 6,
            overflow: 'hidden', marginBottom: 12,
          }}>
            {canaisArr.map(([k, v]) => (
              <div key={k} style={{
                width: `${v * 100}%`, height: '100%',
                background: CANAIS[k].color,
              }}/>
            ))}
          </div>

          <div style={{
            display: 'flex', flexDirection: 'column', gap: 6,
          }}>
            {canaisArr.map(([k, v]) => (
              <div key={k} style={{
                display: 'flex', alignItems: 'center', gap: 10,
                fontSize: 13,
              }}>
                <CanalDot canal={k} size={8}/>
                <span style={{ flex: 1, color: 'var(--ink-2)' }}>
                  {CANAIS[k].label}
                </span>
                <span style={{
                  fontVariantNumeric: 'tabular-nums', color: 'var(--ink)',
                  fontWeight: 500,
                }}>{Math.round(v * 100)}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <TabBar active="insights" onGo={onGo}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 3) Conta
// ─────────────────────────────────────────────────────────────
function ContaRow({ icon, label, value, danger = false, onClick, isLast }) {
  return (
    <button onClick={onClick}
            style={{
              display: 'flex', alignItems: 'center', gap: 14,
              padding: '14px 16px', background: 'transparent',
              border: 0, cursor: 'pointer', width: '100%', textAlign: 'left',
              borderBottom: isLast ? 'none' : '0.5px solid var(--line)',
            }}>
      <div style={{
        width: 28, height: 28, borderRadius: 8,
        background: danger ? 'var(--accent-tint)' : 'var(--bg-muted)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: danger ? 'var(--accent)' : 'var(--ink-2)',
        flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontSize: 15,
          color: danger ? 'var(--accent)' : 'var(--ink)',
          fontWeight: danger ? 500 : 400,
          letterSpacing: '-0.01em',
        }}>{label}</div>
      </div>
      {value && (
        <div style={{ fontSize: 13, color: 'var(--ink-3)' }}>{value}</div>
      )}
      {!danger && (
        <IconChevron size={14} style={{ color: 'var(--ink-4)', flexShrink: 0 }}/>
      )}
    </button>
  );
}

function ContaSection({ title, children }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{
        padding: '8px 20px 10px',
        fontSize: 11, textTransform: 'uppercase',
        letterSpacing: '0.16em', color: 'var(--ink-3)',
        fontWeight: 500,
      }}>{title}</div>
      <div style={{
        margin: '0 16px',
        background: 'var(--bg-card)', borderRadius: 16,
        overflow: 'hidden', boxShadow: 'var(--sh-1)',
      }}>{children}</div>
    </div>
  );
}

function ContaScreen({ onSignOut, onGo, dark, onToggleDark }) {
  return (
    <div className="app-scroll">
      <div className="topbar-pad"/>

      <div className="cat-header" style={{ paddingBottom: 8 }}>
        <div className="cat-eyebrow">Perfil</div>
        <h1 className="cat-title">Conta</h1>
      </div>

      {/* Profile card */}
      <div style={{ padding: '8px 16px 16px' }}>
        <div style={{
          background: 'var(--bg-card)', borderRadius: 22,
          padding: '20px 20px 22px',
          display: 'flex', alignItems: 'center', gap: 16,
          boxShadow: 'var(--sh-1)',
        }}>
          <div style={{
            width: 64, height: 64, borderRadius: 999,
            background: 'var(--ink)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: 'var(--bg-app)',
            fontFamily: 'var(--font-display)', fontStyle: 'italic',
            fontSize: 28, letterSpacing: '-0.02em',
            flexShrink: 0,
          }}>{USER.iniciais}</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{
              fontFamily: 'var(--font-display)', fontSize: 26,
              lineHeight: 1.0, color: 'var(--ink)',
              letterSpacing: '-0.015em',
            }}>{USER.nome}</div>
            <div style={{
              fontSize: 12, color: 'var(--ink-3)', marginTop: 4,
            }}>{USER.email}</div>
            <div style={{
              display: 'inline-flex', alignItems: 'center', gap: 6,
              marginTop: 8,
              padding: '3px 8px', borderRadius: 999,
              background: 'var(--accent-tint)',
              fontSize: 10, color: 'var(--accent-deep)',
              fontWeight: 500, letterSpacing: '0.06em',
              textTransform: 'uppercase',
              whiteSpace: 'nowrap',
              overflow: 'hidden', textOverflow: 'ellipsis',
              maxWidth: '100%',
            }}>
              Vendedor · {USER.empresa}
            </div>
          </div>
        </div>
      </div>

      <ContaSection title="Conta">
        <ContaRow icon={<IconUser size={16}/>} label="Nome" value="Marina V." onClick={() => {}}/>
        <ContaRow icon={<IconMail size={16}/>} label="E-mail" value={USER.email.split('@')[0] + '…'} onClick={() => {}}/>
        <ContaRow icon={<IconLock size={16}/>} label="Senha" value="Trocar" onClick={() => {}}/>
        <ContaRow icon={<IconCube size={16}/>} label="Empresa" value={USER.empresa.split(' ')[0]} isLast onClick={() => {}}/>
      </ContaSection>

      <ContaSection title="Preferências">
        <ContaRow icon={<IconSparkle size={16}/>}
                  label="Notificações"
                  value="Ativas"
                  onClick={() => {}}/>
        {/* Linha com toggle inline */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 14,
          padding: '14px 16px',
          borderBottom: '0.5px solid var(--line)',
        }}>
          <div style={{
            width: 28, height: 28, borderRadius: 8,
            background: 'var(--bg-muted)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: 'var(--ink-2)', flexShrink: 0,
          }}>
            <IconEye size={16}/>
          </div>
          <div style={{ flex: 1, fontSize: 15, color: 'var(--ink)' }}>
            Modo escuro
          </div>
          <button onClick={() => onToggleDark && onToggleDark(!dark)}
                  style={{
                    position: 'relative', width: 44, height: 26,
                    borderRadius: 999, border: 0, padding: 0,
                    background: dark ? 'var(--accent)' : '#d1cdc4',
                    transition: 'background .15s',
                    cursor: 'pointer',
                  }}>
            <i style={{
              position: 'absolute', top: 3, left: dark ? 21 : 3,
              width: 20, height: 20, borderRadius: '50%',
              background: '#fff',
              boxShadow: '0 1px 3px rgba(0,0,0,0.25)',
              transition: 'left .18s cubic-bezier(.3,.7,.4,1)',
            }}/>
          </button>
        </div>
        <ContaRow icon={<IconGrid size={16}/>}
                  label="Idioma"
                  value="Português"
                  isLast
                  onClick={() => {}}/>
      </ContaSection>

      <ContaSection title="Sobre">
        <ContaRow icon={<IconQR size={16}/>} label="Sobre a TROVATA" onClick={() => {}}/>
        <ContaRow icon={<IconRuler size={16}/>} label="Termos e privacidade" onClick={() => {}}/>
        <ContaRow icon={<IconMsg size={16}/>} label="Falar com suporte"
                  value="ajuda@trovata.com.br" isLast onClick={() => {}}/>
      </ContaSection>

      <ContaSection title="">
        <ContaRow icon={<IconBack size={16}/>}
                  label="Sair"
                  danger
                  isLast
                  onClick={onSignOut}/>
      </ContaSection>

      <div style={{
        padding: '20px 20px 120px', textAlign: 'center',
        fontSize: 11, color: 'var(--ink-4)',
        fontFamily: 'var(--font-mono)', letterSpacing: '-0.01em',
      }}>
        TROVATA · v0.1.0 (build 1) · ©  2026 Trovata Birigui
      </div>

      <TabBar active="me" onGo={onGo}/>
    </div>
  );
}

Object.assign(window, {
  CompartilhadosScreen, InsightsScreen, ContaScreen,
});
